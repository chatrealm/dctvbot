# file: lib/dctvbot.rb

require 'cleverbot'
require 'yaml'

require_relative 'services/dctv_api'
require_relative 'services/dctv_channel_checker'
require_relative 'services/google_calendar'
require_relative 'services/irc'

class Dctvbot

    def initialize(config_file)
        # load config
        config = YAML.load(File.open config_file)

        # cleverbot instance
        @cleverbot = Cleverbot.new(config[:cleverbot_io][:api_user], config[:cleverbot_io][:api_key])
        #@cleverbot.nick = 'dctvbot'

        # google calendar instance
        @google_calendar = Services::GoogleCalendar.new(config[:google][:api_key])

        # dctv api instance
        @dctv_api = Services::DctvApi.new(config[:dctv_api][:secs_pro], config[:dctv_api][:title_salt])

        # irc (cinch) instance
        @irc = Services::Irc.new(config[:irc], @cleverbot, @google_calendar, @dctv_api)
    end

    def start
        @channel_checker_thread = Thread.new { Services::DctvChannelChecker.new(@dctv_api, @irc.cinch_bot).start }
        @irc.start
    end

    def shutdown(message='Shutting down')
        @channel_checker_thread.kill
        @irc.shutdown(message)
    end

    private

        attr_accessor :channel_checker_thread, :cleverbot, :config, :dctv_api, :google_calendar, :irc
end
