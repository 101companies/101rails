class UpdateUser < Sequent::Core::Command
  validates :name, presence: true
  validates :email, presence: true

  attrs name: String, email: String, role: String, developer: String
end
