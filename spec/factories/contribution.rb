# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :contributionPage, parent: :page do
    title { 'SomeTitle' }
    namespace { 'Contribution' }
    raw_content { "== Headline ==\n\nThe argument of an [[abstraction]]\n\n== Details ==\n\nFor instance, a function may have an argument or several.\n\nThere are formal and actual arguments.\n\nA formal argument is declared by the abstraction, e.g., in a function definition.\n\nAn actual argument is provided by the use of the abstraction, e.g., in a function application.\n\n== Metadata ==\n\n* [[memberOf::Vocabulary:Programming]]\n* [[relatesTo::Result]]\n* [[isA::Concept]]\n\n" }
  end
end
