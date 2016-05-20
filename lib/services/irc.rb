# file: lib/services/irc.rb

require 'cinch'
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'

require_relative '../cinch/plugins/announcer'
require_relative '../cinch/plugins/dctv_calendar'
require_relative '../cinch/plugins/dctv_second_screen'
require_relative '../cinch/plugins/dctv_status'
require_relative '../cinch/plugins/kill'
require_relative '../cinch/plugins/personality'
require_relative '../cinch/plugins/plugin_management'
require_relative '../cinch/plugins/topic_updater'

module Services
	class Irc
		attr_reader :cinch_bot

		def initialize(irc_settings, cleverbot, google_calendar, dctv_api)
			@cinch_bot = Cinch::Bot.new do
				configure do |c|
					# Server Info
					c.server	= irc_settings[:server]
					c.port		= irc_settings[:port]

					# Bot User Info
					c.nick			= irc_settings[:nick]
					c.user			= irc_settings[:user]
					c.realname		= irc_settings[:realname]
					c.channels		= irc_settings[:channels]
					c.delay_joins	= irc_settings[:delay_joins]

					# Authentication Extension Settings
				    c.authentication			= Cinch::Configuration::Authentication.new
				    c.authentication.strategy	= :channel_status
				    c.authentication.level		= :v

					# Load Up Plugins
					c.plugins.plugins = [
						Cinch::Plugins::Announcer,
						Cinch::Plugins::DctvCalendar,
						Cinch::Plugins::DctvSecondScreen,
						Cinch::Plugins::DctvStatus,
						Cinch::Plugins::Identify,
						Cinch::Plugins::Kill,
						Cinch::Plugins::Personality,
						Cinch::Plugins::PluginManagement,
						Cinch::Plugins::TopicUpdater
					]

					# Set Plugin Options
					c.plugins.options = {
						Cinch::Plugins::DctvCalendar => {
							google_calendar: google_calendar
						},
						Cinch::Plugins::DctvSecondScreen => {
							dctv_api: dctv_api
						},
						Cinch::Plugins::DctvStatus => {
							dctv_api: dctv_api
						},
						Cinch::Plugins::Identify => {
							type: :nickserv,
							password: irc_settings[:password]
						},
						Cinch::Plugins::Personality => {
							cleverbot: cleverbot
						},
						Cinch::Plugins::TopicUpdater => {
							authentication_level: :h,
							default_topic: irc_settings[:default_topic]
						}
					}
				end
			end
		end

		def start
			@cinch_bot.start
		end

		def shutdown(message='Shutting down')
			@cinch_bot.quit(message)
		end
	end
end
