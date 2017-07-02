# coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :page do
    sequence :title do |n|
      "Some title #{n}"
    end
    namespace 'Contribution'
    raw_content "== Headline ==\n\nThe argument of an [[Abstraction]]\n\n== Details ==\n\nFor instance, a function may have an argument or several.\n\nThere are formal and actual arguments.\n\nA formal argument is declared by the abstraction, e.g., in a function definition.\n\nAn actual argument is provided by the use of the abstraction, e.g., in a function application.\n\n== Metadata ==\n\n* [[memberOf::Vocabulary:Programming]]\n* [[relatesTo::Result]]\n* [[isA::Concept]]\n\n"
    verified true
  end

  factory :foobar_page, parent: :page do
    raw_content "== Metadata ==\n\n* [[similarTo::Section:FooBar]]"
  end

  factory :abstraction_page, parent: :page do
    title 'Abstraction'
    namespace 'Concept'
    raw_content 'Some stuff'
  end

  factory :property_having_page, parent: :page do
    raw_content "== Metadata ==\n[[domainOf::SomeDomain]]"
  end

  factory :technology_having_page, parent: :page do
    raw_content "== Metadata ==\n[[uses::Technology:Tech]]"
  end

  factory :technology_page, parent: :page do
    title 'Tech'
    namespace 'Technology'
  end

  factory :property_page, parent: :page do
    title 'domainOf'
    namespace 'Property'
  end

  factory :contributor_page, parent: :page do
    title 'Kevin'
    namespace 'Contributor'
  end

  factory :concept_page, parent: :page do
    title 'Something conceptish'
    namespace 'Concept'
  end

  factory :page_without_metadata, parent: :page do
    raw_content "== Headline ==\n\nThe argument of an [[abstraction]]\n\n== Details ==\n\nFor instance, a function may have an argument or several.\n\nThere are formal and actual arguments.\n\nA formal argument is declared by the abstraction, e.g., in a function definition.\n\nAn actual argument is provided by the use of the abstraction, e.g., in a function application.\n\n"
  end

  factory :page_with_long_headline, parent: :page do
    title 'X' * 255
  end

  factory :page_with_no_headline, parent: :page do
    raw_content "== Some text =="
  end

  factory :page_with_changes, parent: :page do
    after(:create) do |page, evaluator|
      page.page_changes << create(:page_change, title: 'other title', created_at: Time.now - 2.seconds)
      page.page_changes << create(:page_change)
    end
  end

  factory :unverified_page, parent: :page do
    title 'Abstraction'
    namespace 'Concept'
    raw_content 'Some stuff'
    verified 0
  end
end
