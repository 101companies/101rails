class UnverifyPage < Sequent::Core::UpdateCommand
  validates :user_id, presence: true
  validates :full_title, presence: true

  attrs user_id: String, full_title: String
end
