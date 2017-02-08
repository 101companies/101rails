class UpdatePage < Sequent::Core::UpdateCommand
  validates :content, presence: true
  validates :full_title, presence: true

  attrs content: String, full_title: String, user_id: String
end
