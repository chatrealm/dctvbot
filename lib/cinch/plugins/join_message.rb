module Cinch
  module Plugins

    class JoinMessage
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      set :help_msg, "!setjoin [on|off|status|<message>] - Turns on/off, displays status of, or sets message on channel join to <message>."

      def initialize(*args)
        super
        @join_message = "Welcome to Chatrealm!"
        @message_active = false
      end

      listen_to :join
      def listen(m)
        return unless m.channel == Channel(@bot.channels[0])
        m.user.notice @join_message if @message_active
      end

      match /setjoin (.+)/
      def execute(m, input)
        return unless authenticated?(m)
        reply = "Join message is"
        case input
        when 'off'
          if @message_active
            @message_active = false
            reply += " now off"
          else
            reply += " already off"
          end
        when 'on'
          if @message_active
            reply += " already on"
          else
            @message_active = true
            reply += " now on"
          end
        when 'status'
          on_off = @message_active ? "on" : "off"
          reply += " #{on_off} and set to ''#{@join_message}'"
        else
          @join_message = input
          reply += " changed to: #{@join_message}"
        end
        m.user.notice reply
      end

    end

  end
end
