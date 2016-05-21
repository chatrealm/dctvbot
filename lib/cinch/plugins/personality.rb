# file: lib/cinch/plugins/personality.rb

require 'cinch'

module Cinch
    module Plugins

        class Personality
            include Cinch::Plugin

            match lambda { |m| /(.*\s?)@?#{m.bot.nick}[:,]?(\s*.*)/i }, use_prefix: false

            def initialize(*args)
                super
                @cleverbot = config[:cleverbot]
            end

            def execute(m, part_one, part_two=nil)
                response = @cleverbot.say "#{part_one.strip} #{part_two.strip}"
                m.reply(CGI.unescape_html(response), true)
            end

            private

                attr_accessor :cleverbot
        end

    end
end
