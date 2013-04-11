# http://dev.mensfeld.pl/2012/08/simple-rubyrails-passenger-memory-consumption-limit-monitoring/
# Finds bloating passengers and try to kill them gracefully.
# @example:
#   PassengerMonitor.run
require 'logger'
 
 
class PassengerMonitor
  # How much memory (MB) single Passenger instance can use
  DEFAULT_MEMORY_LIMIT = 1500
  # Log file name
  DEFAULT_LOG_FILE = 'passenger_monitoring.log'
  # How long should we wait after graceful kill attempt, before force kill
  WAIT_TIME = 10
 
  def self.run(params = {})
    new(params).check
  end
 
  # Set up memory limit, log file and logger
  def initialize(params = {})
    @memory_limit = params[:memory_limit] || DEFAULT_MEMORY_LIMIT
    @log_file = params[:log_file] || DEFAULT_LOG_FILE
    @logger = Logger.new(@log_file)
  end
 
  # Check all the Passenger processes
  def check
    @logger.info 'Checking for bloated Passenger workers'
 
    `passenger-memory-stats`.each_line do |line|
      next unless line =~ /Rack: /
 
      pid, memory_usage =  extract_stats(line)
      puts pid
 
      # If a given passenger process is bloated try to
      # kill it gracefully and if it fails, force killing it
      if bloated?(pid, memory_usage)
        kill(pid)
        wait
        kill!(pid) if process_running?(pid)
      end
    end
 
    @logger.info 'Finished checking for bloated Passenger workers'
  end
 
  private
 
  # Check if a given process is still running
  def process_running?(pid)
    Process.getpgid(pid) != -1
  rescue Errno::ESRCH
    false
  end
 
  # Wait for process to be killed
  def wait
    @logger.error "Waiting for worker to shutdown..."
    sleep(WAIT_TIME)
  end
 
  # Kill it gracefully
  def kill(pid)
    @logger.error "Trying to kill #{pid} gracefully..."
    Process.kill("SIGUSR1", pid)
  end
 
  # Kill it with fire
  def kill!(pid)
    @logger.fatal "Force kill: #{pid}"
    Process.kill("TERM", pid)
  end
 
  # Extract pid and memory usage of a single Passenger
  def extract_stats(line)
    stats = line.split
    return stats[0].to_i, stats[2].to_f
  end
 
  # Check if a given process is exceeding memory limit
  def bloated?(pid, size)
    bloated = size > @memory_limit
    @logger.error "Found bloated worker: #{pid} - #{size}MB" if bloated
    bloated
  end
 
end