FactoryGirl.define do
  factory :repo_link do
    repo "pythonSyb"
    folder "/contributions/pythonSyb"
    user "kevin-klein"
    page
  end

  factory :repo_link_without_page, parent: :repo_link do
    page nil
    folder '/contributions_from_repo/pythonSyb'
  end

  factory :repo_link_to_root_folder, parent: :repo_link do
    folder '/'
  end

end
