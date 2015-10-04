# coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :page_change do
    title 'Page Change Title'
    namespace 'some namespace'
    raw_content '== Title =='
    user
  end

end
