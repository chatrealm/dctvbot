# file: lib/cinch/plugins/update_topic.rb

require 'cinch'
require 'cinch/extensions/authentication'

require_relative '../../helpers/message_helper'

module Cinch
    module Plugins

        class UpdateTopic
            include Cinch::Plugin
            include Cinch::Extensions::Authentication

            enable_authentication

            listen_to :set_topic, method: :set_topic
            listen_to :update_topic, method: :update_topic

			match(/topic reset$/,		method: :reset_topic,		group: :topic)
			match(/topic default (.*)/,	method: :set_default_topic,	group: :topic)
			match(/topic (.*)/,			method: :change_topic,		group: :topic)

			def initialize(*args)
				super
				@default_topic = config[:default_topic]
			end

            def set_topic(m, channel, new_topic)
                Channel(channel).topic = new_topic
            end

            def update_topic(m, channel, new_data)
                new_topic = MessageHelper.replace_first_message_section(channel.topic, new_data)
                set_topic(m, channel, new_topic)
            end

			def reset_topic(m)
				set_topic(m, m.channel, @default_topic)
			end

			def set_default_topic(m, new_default)
				@default_topic = new_default
				reset_topic(m)
			end

			def change_topic(m, new_data)
				update_topic(m, m.channel, new_data)
			end

			private

				attr_accessor :default_topic
        end

    end
end
