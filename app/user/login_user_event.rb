class LoginUserEvent < Sequent::Core::Event

  attrs email: String,
    name: String,
    github_name: String,
    github_avatar: String,
    github_token: String,
    github_uid: String
end
