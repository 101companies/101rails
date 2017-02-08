Sequent.configure do |config|
  config.command_handlers = [PageCommandHandler.new, UserCommandHandler.new]
end
