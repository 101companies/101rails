FactoryBot.define do
  factory :chapter do
    url {"https://learnyouahaskell.com/"}
    name {"Learn you a haskell"}
    checksum {"343af5d"}
    book
  end

  factory :invalid_chapter, parent: :chapter do
    name {nil}
  end

  factory :new_chapter, parent: :chapter do
    name {'some other book'}
  end

end
