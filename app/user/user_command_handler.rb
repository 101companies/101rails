class UserCommandHandler < Sequent::Core::BaseCommandHandler

  on LoginUser do |command|
    repository.add_aggregate User.new(command)
  end

end
