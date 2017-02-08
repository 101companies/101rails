class VerifyPage < Sequent::Core::UpdateCommand
  validates :full_title, presence: true
  validates :user_id, presence: true

  attrs user_id: String, full_title: String
end
