Sequent.configure do |config|
  config.command_handlers = [PageCommandHandler.new, UserCommandHandler.new]
  config.event_handlers = [PageProjector.new]
end
