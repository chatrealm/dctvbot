require 'yaml'
require 'cinch'
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'

module Cinch::Plugin::ClassMethods
  attr_accessor :help_msg
end

class Cinch::Bot
  attr_accessor :assignedchannels
  attr_accessor :twitter
end

require_relative 'lib/cinch/plugins/check_twitter'
require_relative 'lib/cinch/plugins/clever_bot'
require_relative 'lib/cinch/plugins/google_it'
require_relative 'lib/cinch/plugins/help'
require_relative 'lib/cinch/plugins/join_message'
require_relative 'lib/cinch/plugins/kill'
require_relative 'lib/cinch/plugins/plugin_management'
require_relative 'lib/cinch/plugins/straw_poll'
require_relative 'lib/cinch/plugins/urban_dict'
require_relative 'lib/cinch/plugins/wikipedia'
require_relative 'lib/cinch/plugins/wolfram'

require_relative 'lib/dctv/plugins/channel_status'
require_relative 'lib/dctv/plugins/check_dctv'
require_relative 'lib/dctv/plugins/second_screen'

require_relative 'lib/watcher'

config_file = YAML.load(File.open 'config.test.yml')

dctvbot = Cinch::Bot.new do
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
      Cinch::Plugins::GoogleIt,
      Cinch::Plugins::Help,
      Cinch::Plugins::Identify,
      Cinch::Plugins::JoinMessage,
      Cinch::Plugins::Kill,
      Cinch::Plugins::PluginManagement,
      Cinch::Plugins::StrawPoll,
      Cinch::Plugins::UrbanDict,
      Cinch::Plugins::Wikipedia,
      Cinch::Plugins::Wolfram,

      DCTV::Plugins::ChannelStatus,
      DCTV::Plugins::CheckDCTV,
      DCTV::Plugins::SecondScreen
    ]

    # Set Plugin Options
    c.plugins.options = {
      Cinch::Plugins::Identify => {
        type: :nickserv,
        password: config_file['bot']['password']
      },
      Cinch::Plugins::GoogleIt => {
        google_api_key: config_file['plugins']['google']['api']
      },
      Cinch::Plugins::Kill => {
        authentication_level: config_file['authentication']['admin-level']
      },
      Cinch::Plugins::PluginManagement => {
        authentication_level: config_file['authentication']['admin-level']
      },
      Cinch::Plugins::UrbanDict => {
        max_length: 300
      },
      Cinch::Plugins::Wikipedia => {
        max_length: 300
      },
      Cinch::Plugins::Wolfram => {
        max_length: 300,
        wolfram_api_key: config_file['plugins']['wolfram']['api']
      },

      DCTV::Plugins::ChannelStatus => {
        google_api_key:  config_file['plugins']['google']['api']
      },
      DCTV::Plugins::SecondScreen => {
        pastebin_api_key: config_file['plugins']['second-screen']['pastebin-api']
      }
    }
  end

  # Set Twitter Endpoint
  @twitter = Twitter::REST::Client.new do |c|
    c.consumer_key        = config_file['plugins']['twitter']['consumer-key']
    c.consumer_secret     = config_file['plugins']['twitter']['consumer-secret']
    c.access_token        = config_file['plugins']['twitter']['access-token']
    c.access_token_secret = config_file['plugins']['twitter']['access-token-secret']
  end

  # Handle SIGINT (Ctrl-C)
  trap "SIGINT" do
    bot.debug "Caught SIGINT, quitting..."
    bot.quit
  end

  # Handle SIGTERM (Kill Command)
  trap "SIGTERM" do
    bot.debug "Caught SIGTERM, quitting..."
    bot.quit
  end
end

# Start watcher threads
Thread.new { Watcher.new(dctvbot, :check_dctv).start }
Thread.new { Watcher.new(dctvbot, :check_twitter, 300).start }

# Fire up bot
dctvbot.start
