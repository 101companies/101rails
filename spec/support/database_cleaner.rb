
RSpec.configure do |config|

  config.around(:each) do |example|
    Mongoid::Config.purge!
    example.run
    Mongoid::Config.purge!
  end

end
