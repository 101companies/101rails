class DestroyPage < Sequent::Core::Command
  validates :user_id, presence: true
  validates :full_title, presence: true

  attrs full_title: String, user_id: String
end
