# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :page_change do
    title { 'Page_Change_Title' }
    namespace { 'Concept' }
    raw_content { '== Title ==' }
    user
    page
  end

  factory :other_page_change, parent: :page_change do
    title { 'Other_Change_Title' }
    namespace { 'some other namespace' }
    raw_content { '== Other Title ==' }
    user
    page
  end
end
