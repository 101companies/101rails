class ServicesController < ApplicationController
  require 'fileutils'


  def index
    if !(can? :manage, :all)
      flash[:error] = "Your are not allowed to see this"
      redirect_to '/repos'
      return
    end

    worker_path = SystemSetting.find_by(name: 'Worker_Path')
    result_path = SystemSetting.find_by(name: 'Result_Path')
    data_path = SystemSetting.find_by(name: 'Data_Path')
    web_path = SystemSetting.find_by(name: 'Web_Path')
    max_size_raw_repo = SystemSetting.find_by(name: 'Maximum_Size_Raw_Repo')
    max_size_repo = SystemSetting.find_by(name: 'Maximum_Size_Repo')
    stop = SystemSetting.find_by(name: 'Stop')
    actual_size_raw_repo = SystemSetting.find_by(name: 'Actual_Size_Raw_Repo')
    actual_size_repo = SystemSetting.find_by(name: 'Actual_Size_Repo')

    if actual_size_raw_repo == nil
      actual_size_raw_repo = SystemSetting.create(name: 'Actual_Size_Raw_Repo', value: "0")
    end
    if actual_size_repo == nil
      actual_size_repo = SystemSetting.create(name: 'Actual_Size_Repo', value: "0")
    end
    @actual_size_raw_repo = actual_size_raw_repo.value
    @actual_size_repo = actual_size_repo.value

    if worker_path == nil
      worker_path = SystemSetting.create(name: 'Worker_Path', value:'')
    end
    @worker = worker_path.value

    if data_path == nil
      data_path = SystemSetting.create(name: 'Data_Path', value:'')
    end
    @data = data_path.value

    if result_path == nil
      result_path = SystemSetting.create(name: 'Result_Path', value:'')
    end
    @result = result_path.value

    if web_path == nil
      web_path = SystemSetting.create(name: 'Web_Path', value:'')
    end
    @web = web_path.value

    if max_size_raw_repo == nil
      max_size_raw_repo = SystemSetting.create(name: 'Maximum_Size_Raw_Repo', value: 0)
    end
    @max_raw_repo = max_size_raw_repo.value

    if max_size_repo == nil
      max_size_repo = SystemSetting.create(name: 'Maximum_Size_Repo', value: 0)
    end
    @max_repo = max_size_repo.value

    if stop == nil
      stop = SystemSetting.create(name: 'Stop', value: -1)
    end
    @stop = stop.value.to_i

    @completed = Repo.where(state: 2)
    @in_progress = Repo.where(state: 1)
    @in_queue = Repo.where(state: 0)
  end

  def stop
    if !can? :manage, :all
      redirect_to '/repos'
      return
    end
    stop = SystemSetting.find_by(name: 'Stop')
    if stop.value.to_i == -1
      if SystemSetting.find_by(name: 'Web_Path').value == "" || SystemSetting.find_by(name: 'Data_Path').value == "" ||
          SystemSetting.find_by(name: 'Result_Path').value == "" ||
          SystemSetting.find_by(name: 'Worker_Path').value == ""
        flash[:error] = "Please fill in all Paths before starting the service."
        redirect_to '/service'
        return
      end
    end
    modul = SystemSetting.find_by(name: 'Module_Dependencies')
    if modul == nil
      modul = SystemSetting.create(name: 'Module_Dependencies', value: '{}')
    end
    nvalue = stop.value.to_i*-1
    stop.value = nvalue.to_s
    stop.save
    @stop = stop.value
    redirect_to '/service'
  end



  def reset
    if !can? :manage, :all
      redirect_to '/repos'
      return
    end
    stop = SystemSetting.find_by(name: 'Stop')
    if stop.value.to_i == 1
      flash[:error] = 'Please stop the service first'
      redirect_to '/service'
      return
    end
    all_raw_repos = RawRepo.all
    all_raw_repos.each do |raw_repo|
      raw_repo.destroy
    end
    actual_size_raw_repo = SystemSetting.find_by(name: 'Actual_Size_Raw_Repo')
    actual_size_raw_repo.value = "0"
    actual_size_raw_repo.save
    actual_size_repo = SystemSetting.find_by(name: 'Actual_Size_Repo')
    actual_size_repo.value = "0"
    actual_size_repo.save

    result_path = SystemSetting.find_by(name: 'Result_Path')
    data_path = SystemSetting.find_by(name: 'Data_Path')
    if Dir.exists? (result_path.value)
      FileUtils.remove_dir result_path.value
    end

    if Dir.exists? (data_path.value)
      FileUtils.remove_dir data_path.value
    end

    redirect_to '/service'
  end

  def manage
    if !can? :manage, :all
      flash[:error] = "You are not allowed to see this"
      redirect_to '/repos'
      return
    end
    data = params.require('serviceData').permit(:web,:data,:result,:worker,:maxRawRepo,:maxRepo)
    web = SystemSetting.find_by(name: 'Web_Path')
    web.value = data[:web]
    web.save
    datas = SystemSetting.find_by(name: 'Data_Path')
    datas.value = data[:data]
    datas.save
    result = SystemSetting.find_by(name: 'Result_Path')
    result.value = data[:result]
    result.save
    worker = SystemSetting.find_by(name: 'Worker_Path')
    worker.value = data[:worker]
    worker.save
    max_raw_repo = SystemSetting.find_by(name: 'Maximum_Size_Raw_Repo')
    max_raw_repo.value = data[:maxRawRepo]
    max_raw_repo.save
    max_repo = SystemSetting.find_by(name: 'Maximum_Size_Repo')
    max_repo.value = data[:maxRepo]
    max_repo.save
    redirect_to '/service'
  end

end
