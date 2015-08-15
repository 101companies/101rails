# coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :user do
    name 'user'
    github_uid SecureRandom.hex
    github_token SecureRandom.hex
    github_name 'test'
    email 'test@test.com'
    role 'admin'
  end

end
