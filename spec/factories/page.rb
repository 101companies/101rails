# coding: utf-8
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :page do
    title 'Some Contribution'
    namespace 'Contribution'
    raw_content "== Headline ==\n\nThe argument of an [[abstraction]]\n\n== Details ==\n\nFor instance, a function may have an argument or several.\n\nThere are formal and actual arguments.\n\nA formal argument is declared by the abstraction, e.g., in a function definition.\n\nAn actual argument is provided by the use of the abstraction, e.g., in a function application.\n\n== Metadata ==\n\n* [[memberOf::Vocabulary:Programming]]\n* [[relatesTo::Result]]\n* [[isA::Concept]]\n\n"
  end

  factory :abstraction_page, parent: :page do
    title 'Abstraction'
    namespace 'Concept'
    raw_content 'Some stuff'
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

end
