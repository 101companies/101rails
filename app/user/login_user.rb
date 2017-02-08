class LoginUser < Sequent::Core::Command
  validates :email, presence: true
  validates :github_token, presence: true
  validates :github_uid, presence: true

  attrs email: String,
    name: String,
    github_name: String,
    github_avatar: String,
    github_token: String,
    github_uid: String
end
