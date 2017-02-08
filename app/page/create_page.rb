class CreatePage < Sequent::Core::Command
  validates :content, presence: true, allow_blank: true
  validates :full_title, presence: true

  attrs content: String, full_title: String, user_id: String
end
