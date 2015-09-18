# encoding: utf-8

module Plugins
  class CommandControl

    include Cinch::Plugin
    include Cinch::Extensions::Authentication

    enable_authentication
    match /turn (.+) (.+)/

    def initialize(*args)
      super
      @bot.cleverbot_enabled = true
      @bot.dctv_commands_enabled = true
    end

    def execute(m, group, action)
      failed = true unless ["on", "off"].include?(action)
      case group
      when "cleverbot"
        @bot.cleverbot_enabled = toggle_command_set(m, "Cleverbot interfaces", action, @bot.cleverbot_enabled)
      when "dctv"
        @bot.dctv_commands_enabled = toggle_command_set(m, "DCTV commands", action, @bot.dctv_commands_enabled)
      when "all"
        @bot.cleverbot_enabled = toggle_command_set(m, "Cleverbot interfaces", action, @bot.cleverbot_enabled)
        @bot.dctv_commands_enabled = toggle_command_set(m, "DCTV commands", action, @bot.dctv_commands_enabled)
      else
        @failed = true
      end

      m.user.notice "Sorry, I don't know how to turn #{group} #{action}" if failed
    end

    private

      def toggle_command_set(m, command_set_name, action, command_boolean_variable)
        case action
        when "on"
          turn_off = false
        when "off"
          turn_off = true
        end

        if turn_off
          command_boolean_variable ? m.user.notice("#{command_set_name} have been disabled") : m.user.notice("#{command_set_name} are already disabled")
          return false
        else
          command_boolean_variable ? m.user.notice("#{command_set_name} are already enabled") : m.user.notice("#{command_set_name} have been enabled")
          return true
        end
      end
  end

end
