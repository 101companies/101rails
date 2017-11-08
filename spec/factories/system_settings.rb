FactoryGirl.define do
  factory :system_setting, class: 'SystemSetting' do
    factory :system_setting_actual_size_repo do
      name "Actual_Size_Repo"
      value "0"
    end
    factory :system_setting_maximum_size_repo do
      name "Maximum_Size_Repo"
      value "10000000"
    end
    factory :system_setting_actual_size do
      name "Actual_Size_Raw_Repo"
      value "0"
    end
    factory :system_setting_maximum_size_zero do
      name "Maximum_Size_Raw_Repo"
      value "0"
    end
    factory :system_setting_maximum_size_high do
      name "Maximum_Size_Raw_Repo"
      value "10000000"
    end
    factory :system_setting_result_path do
      name "Result_Path"
      value "ENTERPATHHERE----/test/result"
    end
    factory :system_setting_data_path do
      name "Data_Path"
      value "ENTERPATHHERE----/test/data"
    end
    factory :system_setting_worker_path do
      name "Worker_Path"
      value "ENTERPATHHERE----/101worker"
    end
    factory :system_setting_web_path do
      name "Web_Path"
      value "ENTERPATHHERE----/101web"
    end
  end
end
