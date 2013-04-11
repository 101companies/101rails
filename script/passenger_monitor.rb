file_path = File.expand_path(File.dirname(__FILE__))
# Load PassengerMonitor from '/lib/passenger_monitor.rb'
require File.join(file_path, '..', 'lib', 'passenger_monitor')
 
# Set logger to log into Rails project /log directory and start monitoring
PassengerMonitor.run(
  :log_file => File.join(file_path, '..', 'log', 'passenger_monitor.log')
)