# file: lib/cinch/plugins/dctv_title_suggest.rb

module Cinch
    module Plugins
        class DctvTitleSuggest
            include Cinch::Plugin
            include Cinch::Extensions::Authentication

            match(/t reset$/i,  method: :reset_title_list,  group: :titles)
            match(/t (.+)/,     method: :suggest_title,     group: :titles)

            def initialize(*args)
                super
                @dctv_api = config[:dctv_api]
            end

            def suggest_title(m, suggestion)
                response = @dctv_api.suggest_title(suggestion, m.user.nick)
                m.user.notice response
            end

            def reset_title_list(m)
                return unless authenticated?(m)
                response = @dctv_api.reset_title_suggestions
                m.user.notice response
            end

            private

                attr_accessor :dctv_api
        end
    end
end
