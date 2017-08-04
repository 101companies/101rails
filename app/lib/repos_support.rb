module ReposSupport
  require 'json'


  def getModuleExecutionOrder(modules)
    modules = modules.reverse
    result = []
    modules.each do |m|
      if !result.include?(m)
        result = result + calcDepts(m) + [m]
      end
    end
    result
  end

  def calcDepts(modul)
    
    jsonPath = File.join(SystemSetting.find_by(name: 'Web_Path').value,'data','dumps','moduleDependencies.json')
    modules = SystemSetting.find_by(name: "Module_Dependencies")
    if modules == nil
      SystemSetting.create(name: "Module_Dependencies", value:'{}')
    end
    if File.mtime(jsonPath) > modules.updated_at
      file = File.open(jsonPath)
      data = JSON.parse(file.read)
      modules.value = JSON.generate(data)
      modules.save
      file.close
    end
    data = JSON.parse(modules.value)
    depts = data[modul]
    if depts == []
      return []
    end
    result = []
    depts.each do |d|
      if !result.include?(d)
        result = result + calcDepts(d) +[d]

      end
    end
    result
  end


  def createModulePage(repo, modules)
    newModules = false
    modules.each do |m|
      if repo.part.find_by(name: m) == nil
        newModules = true
        q = repo.part.create(name: m, state: 0)
        q.save
      end
      repo.save
    end
    newModules
  end


  def linkToName(link,rev)
    name = link.chomp('.git')
    parts = name.split('.')
    if parts[0] == 'http://www' || parts[0] == 'https://www'
      parts[0] = 'http://' + parts[1]
      parts[1] = ''
    end
    name = ''
    parts.each {|p|
      if p != ''
        name = name + '_' + p.to_s.downcase
      end}
    parts = name.split('/')
    parts = parts.drop(1)
    name = 'repo'
    parts.each {|p|
      if p != ''
        name = name + '_'+ p.to_s.downcase
      end}
    name+rev
  end
 
  def getModulesFromJson()
    modul = read_module_dependencies
    result = []
    data = JSON.parse(modul.value)
    data.keys.each do |m|
      result.push(m.to_sym)
    end
    result
  end

  def calc_size_of_folder(folder_path)
    size = 0
    path = File.join(folder_path,"**","*")
    files = Dir.glob(path)
    files.each do |file_name|
      size += File.size(file_name)
    end
    return size/1000
  end

  def read_module_dependencies()
    path = File.join(SystemSetting.find_by(name: 'Web_Path').value,'data','dumps','moduleDependencies.json')
    modul = SystemSetting.find_by(name: 'Module_Dependencies')
    if modul == nil
     modul = SystemSetting.create(name: 'Module_Dependencies', value: '{}')
    end
    modul.with_lock do
      if File.mtime(path) > modul.updated_at
        file = File.read path
        data = JSON.parse(file)
        modul.value = JSON.generate(data)
        modul.save
      end
      return modul
    end




  end

end
