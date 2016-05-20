# file: lib/cinch/plugins/dctv_second_screen.rb

require 'cinch'
require 'cinch/extensions/authentication'

module Cinch
    module Plugins

        class DctvSecondScreen
            include Cinch::Plugin
            include Cinch::Extensions::Authentication

            enable_authentication

            match(/secs (.+)/)

            def initialize(*args)
                super
                @dctv_api = config[:dctv_api]
            end

            def execute(m, input)
                response = @dctv_api.set_second_screen(input, m.user.nick)
                m.user.notice response
            end

            private

                attr_accessor :dctv_api
        end

    end
end
