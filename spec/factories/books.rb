FactoryBot.define do
  factory :book do
    name {"Learn you a haskell"}
    url {"http://learnyouahaskell.com"}
  end

  factory :invalid_book, parent: :book do
    name {nil}
  end

  factory :new_book, parent: :book do
    name {'other haskell book'}
  end
end
