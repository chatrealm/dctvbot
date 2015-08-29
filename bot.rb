# encoding: utf-8

require 'bundler/setup'
Bundler.require
require 'yaml'

require_relative 'plugins/dctv/check_dctv'
require_relative 'watcher'

config = YAML.load(File.open "config.yml")

bot = Cinch::Bot.new do
  configure do |c|
    # Server Info
    c.server  = config['server']['host']
    c.port    = config['server']['port']

    # Bot User Info
    c.nick      = config['bot']['nick']
    c.user      = config['bot']['user']
    c.realname  = config['bot']['realname']
    c.channels  = config['bot']['channels']

    c.authentication          = Cinch::Configuration::Authentication.new
    c.authentication.strategy = :channel_status
    c.authentication.level    = :v

    c.plugins.plugins = [
      Cinch::Plugins::Identify,
      Plugins::DCTV::CheckDCTV,
    ]

    c.plugins.options = {
      Cinch::Plugins::Identify => {
        type: :nickserv,
        password: config['bot']['password']
      }
    }
  end

  trap "SIGINT" do
    bot.log("Caught SIGINT, quitting...", :info)
    bot.quit
  end

  trap "SIGTERM" do
    bot.log("Caught SIGTERM, quitting...", :info)
    bot.quit
  end
end

Thread.new { Watcher.new(bot).start }
bot.start
