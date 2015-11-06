require 'cinch'
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'
require 'thread'
require 'yaml'

module Cinch
  module Plugin::ClassMethods
    attr_accessor :help_msg
  end
  class Bot
    attr_accessor :assignedchannels
    attr_accessor :twitter
  end
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

mutex = Mutex.new
quit_signalled = ConditionVariable.new
signal_received = nil
config_file = YAML.load(File.open 'config.yml')

bot = Cinch::Bot.new do
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

  on :connect do bot.set_mode "B" end

  # Set Twitter Endpoint
  @twitter = Twitter::REST::Client.new do |c|
    c.consumer_key        = config_file['plugins']['twitter']['consumer-key']
    c.consumer_secret     = config_file['plugins']['twitter']['consumer-secret']
    c.access_token        = config_file['plugins']['twitter']['access-token']
    c.access_token_secret = config_file['plugins']['twitter']['access-token-secret']
  end
end

# Start watcher threads
Thread.new { Watcher.new(bot, :check_dctv).start }
Thread.new { Watcher.new(bot, :check_twitter, 300).start }

# Handle signals QUIT (Ctrl-\), INT (Ctrl-C), and TERM (Kill Command)
%w[QUIT INT TERM].each do |signal_name|
  Signal.trap(signal_name) do |signal_number|
    signal_received = signal_number
    quit_signalled.signal
  end
end

Thread.new do
  mutex.synchronize do
    quit_signalled.wait(mutex) until signal_received
    bot.quit "Shutdown signal received #{Signal.signame(signal_received)}"
  end
end

# Fire up bot
bot.start
