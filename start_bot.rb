require 'cinch'
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'
require 'yaml'

require_relative 'lib/dctvbot'
require_relative 'lib/watcher'

require_relative 'lib/cinch/plugins/plugin_management'

require_relative 'lib/dctv/plugins/check_dctv'

# Load up config file
config_file = YAML.load(File.open 'config.test.yml')

dctvbot = DCTVBot.new do
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
    c.authentication.level    = :v

    # Load Up Plugins
    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Cinch::Plugins::PluginManagement,
      DCTV::Plugins::CheckDctv
    ]

    # Set Plugin Options
    c.plugins.options = {
      Cinch::Plugins::Identify => {
        type: :nickserv,
        password: config_file['bot']['password']
      }
    }
  end

  # Setup Twitter Endpoint
  # twitter = Twitter::REST::Client.new do |c|
  #   c.consumer_key        = config_file['plugins']['twitter']['consumer-key']
  #   c.consumer_secret     = config_file['plugins']['twitter']['consumer-secret']
  #   c.access_token        = config_file['plugins']['twitter']['access-token']
  #   c.access_token_secret = config_file['plugins']['twitter']['access-token-secret']
  # end

  # Custom Log File
  custom_log_file(config_file['log-file'], :debug)
end

# puts YAML::dump(dctvbot)
# puts YAML::dump(dctvbot.bot)

Thread.new { Watcher.new(dctvbot, :check_dctv).start }
# Thread.new { Watcher.new(dctvbot, :check_twitter, 300).start }

dctvbot.start
