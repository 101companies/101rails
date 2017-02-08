class RenamePage < Sequent::Core::UpdateCommand
  validates :full_title, presence: true
  validates :new_title, presence: true

  attrs full_title: String, new_title: String, user_id: String
end
