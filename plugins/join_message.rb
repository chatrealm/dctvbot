# encoding: utf-8

module Plugins
  class JoinMessage
    
    include Cinch::Plugin
    include Cinch::Extensions::Authentication

    def initialize(*args)
      super
      @current_join_msg = "Welcome to Chatrealm!"
      @do_msg = false
    end

    listen_to :join
    def listen(m)
      if @do_msg
        m.user.notice @current_join_msg
      end
    end

    match /setjoin (.+)/
    def execute(m, input)
      return unless authenticated?(m)
      if input == "off"
        if @do_msg
          @do_msg = false
          m.user.notice "Join message is now off"
        else
          m.user.notice "Join message is already off"
        end
      elsif input == "on"
        if @do_msg
          m.user.notice "Join message is already on"
        else
          @do_msg = true
          m.user.notice "Join message is now on"
        end
      elsif input == "status"
        on_off = @do_msg ? "on" : "off"
        m.user.notice "Join message is #{on_off} and set to \"#{@current_join_msg}\""
      else
        @current_join_msg = input
        m.user.notice "Join message has been changed to: #{@current_join_msg}"
      end
    end

  end
end
