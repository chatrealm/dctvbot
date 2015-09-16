require 'cinch'

class DCTVBot < Cinch::Bot
  def initialize(&b)
    super

    # Handle SIGINT (Ctrl-C)
    trap "SIGINT" do
      debug "Caught SIGINT, quitting..."
      self.quit
    end

    # Handle SIGTERM (Kill Command)
    trap "SIGTERM" do
      debug "Caught SIGTERM, quitting..."
      self.quit
    end
  end

  def custom_log_file(file_name, log_level)
    file = open(file_name, 'a')
    file.sync = true
    self.loggers << Cinch::Logger::FormattedLogger.new(file)
    self.loggers.first.level = log_level
  end

end
