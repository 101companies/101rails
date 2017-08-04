require './lib/repos_support'
require 'fileutils'

class AnalyseJob
  include SuckerPunch::Job
  include ReposSupport
  workers 1

  def perform(link, rev, name, size, modules)
    repo = Repo.find_by(name: name)
    repo.state = 1
    repo.save
    if repo == nil || repo.state != 1
      return
    end
    exec_modules = check_modules(modules, repo)
    if !exec_modules.empty?
      raw_repo = repo.raw_repo
      if raw_repo.state == 0 || raw_repo.state == -1
        check_size(size)
        clone_repo(link, rev, repo)
      else
        update_repo(link, rev, repo)
      end
      if repo.state == 1
        run_modules(repo, exec_modules)
        repo.state = 2
        check_repo_size(repo)
        repo.save
      end
    end
  end

  def save_example_data(repo_name, module_name)
    repo = Repo.find_by(name: repo_name)
    modul = repo.part.find_by(name: module_name)
    dependsOn = []
    webPath = SystemSetting.find_by(name: 'Web_Path').value
    jsonPath = File.join(webPath,'data','dumps','moduleDependencies.json')
    json = JSON.parse(File.open(jsonPath).read)
    json[module_name].each do |mod|
      dependsOn.append(mod)
    end

    examples = Hash.new()
    examples['dump'] = []
    examples['resource'] =[]

    data = Hash.new()
    data['dump'] = []
    data['resource'] = []

    jsonPath = File.join(webPath,'data','dumps','moduleDescriptions.json')
    json = JSON.parse(File.open(jsonPath).read)
    main_entry = ''
    json.each do |entry|
      if entry['name'] == module_name
        main_entry = entry
        break
      end
    end
    if main_entry != ''
      main_entry['behavior']['creates'].each do |keyValue|
        if keyValue[0] == 'resource'
          data['resource'].push(keyValue[1])
        elsif keyValue[0] == 'dump'
          data['dump'].push(keyValue[1])
        end
      end
    end

    result_path = SystemSetting.find_by(name: 'Result_Path').value
    data['dump'].each do |type|
      name = type
      folder_path = File.join(result_path,repo.raw_repo.name,repo.name)
      folder = File.join(folder_path,'dumps',type+'.json')
      folder_link = Dir.glob(folder).take(1)
      content= File.open(folder_link[0]).read
      input = Hash.new()
      folder_link[0] = folder_link[0].reverse.chomp(folder_path.reverse).reverse
      input[name] = [[folder_link[0],content]]
      examples['dump'].push(input)
    end

    data['resource'].each do |type|
      name = type
      input = Hash.new()
      input[name] = []
      folder_path = File.join(result_path,repo.raw_repo.name,repo.name)
      folder = File.join(folder_path,'**','*.'+type+'.json')
      folder_link = Dir.glob(folder).take(3)
      folder_link.each do |folder|
        content= File.open(folder).read
        folder = folder.reverse.chomp(folder_path.reverse).reverse
        input[name].push([folder,content])
      end
      examples['resource'].push(input)
    end


    if examples['dump'] == []
      examples.delete('dump')
    end

    if examples['resource'] == []
      examples.delete('resource')
    end

    modul.result = JSON.generate(examples)
    modul.dependsOn = JSON.generate(dependsOn)
    modul.save
  end

  def check_repo_size(repo)
    result_path = SystemSetting.find_by(name: "Result_Path").value
    actual_repo_size = SystemSetting.find_by(name: "Actual_Size_Repo")
    max_repo_size = SystemSetting.find_by(name: "Maximum_Size_Repo")
    repo_disk_size = calc_size_of_folder(File.join(result_path,repo.raw_repo.name,repo.name))+(File.size(File.join(result_path,repo.raw_repo.name,repo.name+'.zip'))/1000)
    actual_repo_size.value = (actual_repo_size.value.to_i - repo.size + repo_disk_size).to_s
    actual_repo_size.save
    repo.size = repo_disk_size
    repo.save
    while(actual_repo_size.value.to_i > max_repo_size.value.to_i)
      repos = Repo.where(state: 2).order(updated_at: :asc)
      repo = repos[0]
      actual_repo_size.value = (actual_repo_size.value.to_i - repo.size).to_s
      repo.destroy
      actual_repo_size.save
    end
  end

  def run_modules(repo, modules)
    worker_path = SystemSetting.find_by(name: "Worker_Path").value
    result_path = SystemSetting.find_by(name: "Result_Path").value
    data_path = SystemSetting.find_by(name: "Data_Path").value
    modules.each do |mod|
      Dir.chdir(worker_path) do
        cmd = 'bin/run_module_ext '+mod+' '+File.join(data_path,repo.raw_repo.name,'result')+' '+File.join(result_path,repo.raw_repo.name,repo.name)
        system cmd
        modul = repo.part.find_by(name: mod)
        modul.state = 1
        modul.save
        save_example_data(repo.name,modul.name)
        repo.save
      end
    end
    if Dir.exist?(result_path+'/'+repo.raw_repo.name)
      Dir.chdir(result_path+'/'+repo.raw_repo.name) do
        cmd_zip = 'zip -r '+repo.name+'.zip'+' '+repo.name
        system cmd_zip
      end
    end
  end



  def check_size(size)
    data_path = SystemSetting.find_by(name: "Data_Path").value
    q = SystemSetting.find_by(name: "Actual_Size_Raw_Repo")
    maximum_size = SystemSetting.find_by(name: "Maximum_Size_Raw_Repo")
    while(q.value.to_i + size > maximum_size.value.to_i)
      all_finished_repos = RawRepo.where("state = 1")
      all_finished_repos[0].state = 0
      if Dir.exists?(data_path+'/'+all_finished_repos[0].name)
        delPath = data_path+'/'+all_finished_repos[0].name
        FileUtils.remove_dir delPath
      end
      q.value = (q.value.to_i - all_finished_repos[0].size).to_s
      q.save
      all_finished_repos[0].save
    end
  end


  def update_repo(link, rev, repo)
    data_path = SystemSetting.find_by(name: "Data_Path").value
    if Dir.exist?(data_path+'/'+repo.raw_repo.name)
      Dir.chdir(data_path+'/'+repo.raw_repo.name+'/result') do
        rev_successfull = system 'git checkout '+rev
        if !(rev_successfull)
          FileUtils.remove_dir (File.join(data_path,repo.raw_repo.name))
          FileUtils.mkpath (File.join(data_path,repo.raw_repo.name))
          clone_repo(link, rev, repo)
        end
      end
    end
  end



  def clone_repo(link, rev, repo)
    clone_successful = false
    repo_disk_size = -1
    raw_repo = repo.raw_repo
    name = raw_repo.name
    data_path = SystemSetting.find_by(name: "Data_Path").value
    if !Dir.exists?(File.join(data_path,name))
      FileUtils.mkdir_p(File.join(data_path,name))
    end
    Dir.chdir(File.join(data_path,name)) do
      clone_successful = system 'git clone ' + link +' result'
    end
    if clone_successful
      repo_disk_size = calc_size_of_folder(File.join(data_path,name))
    end
    if clone_successful
      if repo_disk_size != -1
        global_size = SystemSetting.find_by(name: "Actual_Size_Raw_Repo")
        global_size.value = (global_size.value.to_i + repo_disk_size).to_s
        raw_repo.size = repo_disk_size
        global_size.save
      end
      repo.state = 1
      raw_repo.state = 1
      raw_repo.save
      repo.save
      update_repo(link, rev, repo)
    else
      repo.raw_repo.destroy
      return
    end
  end


  def check_modules(modules, repo)
    new_mod = []
    modules.each do |m|
      mod = repo.part.find_by(name: m)
      if mod.state == 0
        new_mod.push(m)
      end
    end
    new_mod
  end

end
