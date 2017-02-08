class User < Sequent::Core::AggregateRoot

  def initialize(command)
    super(command.aggregate_id)

    apply LoginUserEvent, email: command.email,
      name: command.name,
      github_name: command.github_name,
      github_avatar: command.github_avatar,
      github_token: command.github_token,
      github_uid: command.github_uid
  end

end
