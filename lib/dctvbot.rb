require 'cinch'
require 'json'
require 'net/http'

class DCTVBot < Cinch::Bot
  # Assigned channels (from dctv api)
  attr_accessor :assignedchannels

  # Command Control
  # attr_accessor :cleverbot_enabled, :dctv_commands_enabled

  # Twitter Endpoint
  # attr_accessor :twitter

  def initialize(&block)
    super

    # Handle SIGINT (Ctrl-C)
    trap "SIGINT" do
      debug "Caught SIGINT, quitting..."
      quit
    end

    # Handle SIGTERM (Kill Command)
    trap "SIGTERM" do
      debug "Caught SIGTERM, quitting..."
      quit
    end
  end

  # Set a custom log file for the bot
  def custom_log_file(file_name, log_level=:info)
    file = open(file_name, 'a')
    file.sync = true # Write buffered data immediately
    @loggers << Cinch::Logger::FormattedLogger.new(file)
    @loggers.first.level = log_level # Set log level
  end

  def primary_channel
    Channel(@channels.first)
  end
end
