require 'cinch'
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'
require 'json'
require 'net/http'

require_relative 'cinch/plugins/check_twitter'
require_relative 'cinch/plugins/clever_bot'
require_relative 'cinch/plugins/join_message'
require_relative 'cinch/plugins/kill'
require_relative 'cinch/plugins/plugin_management'

require_relative 'dctv/plugins/channel_status'
require_relative 'dctv/plugins/check_dctv'
require_relative 'dctv/plugins/second_screen'

class DCTVBot < Cinch::Bot
  # Assigned channels (from dctv api)
  attr_accessor :assignedchannels
  # Twitter Endpoint
  attr_accessor :twitter

  def initialize(config_file)
    super()
    # Define Cinch Configuration
    configure do |c|
      # Server Info
      c.server  = config_file['server']['host']
      c.port    = config_file['server']['port']

      # Bot User Info
      c.nick      = config_file['bot']['nick']
      c.user      = config_file['bot']['user']
      c.realname  = config_file['bot']['realname']
      c.channels  = config_file['bot']['channels']

      # Authentication Plugin Settings
      c.authentication          = Cinch::Configuration::Authentication.new
      c.authentication.strategy = :channel_status
      c.authentication.level    = config_file['authentication']['minimum-level']

      # Load Up Plugins
      c.plugins.plugins = [
        Cinch::Plugins::CheckTwitter,
        Cinch::Plugins::CleverBot,
        Cinch::Plugins::Identify,
        Cinch::Plugins::JoinMessage,
        Cinch::Plugins::Kill,
        Cinch::Plugins::PluginManagement,
        DCTV::Plugins::ChannelStatus,
        DCTV::Plugins::CheckDCTV,
        DCTV::Plugins::SecondScreen
      ]

      # Set Plugin Options
      c.plugins.options = {
        Cinch::Plugins::Identify => { type: :nickserv, password: config_file['bot']['password'] },
        Cinch::Plugins::Kill => { authentication_level: config_file['authentication']['admin-level'] },
        Cinch::Plugins::PluginManagement => { authentication_level: config_file['authentication']['admin-level'] },
        DCTV::Plugins::SecondScreen => { pastebin_api_key: config_file['plugins']['second-screen']['pastebin-api'] }
      }
    end

    # Set Twitter Endpoint
    @twitter = Twitter::REST::Client.new do |c|
      c.consumer_key        = config_file['plugins']['twitter']['consumer-key']
      c.consumer_secret     = config_file['plugins']['twitter']['consumer-secret']
      c.access_token        = config_file['plugins']['twitter']['access-token']
      c.access_token_secret = config_file['plugins']['twitter']['access-token-secret']
    end

    # Set custom Log File
    custom_log_file(config_file['custom-log']['file'], config_file['custom-log']['level'])

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
