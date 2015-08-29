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
      failed = false
      case action
      when "on"
        @turn_off = false
      when "off"
        @turn_off = true
      else
        failed = true
      end

      case group
      when "cleverbot",
        @bot.cleverbot_enabled = toggle_command_set(m, "Cleverbot interfaces", @bot.cleverbot_enabled)
      when "dctv"
        @bot.dctv_commands_enabled = toggle_command_set(m, "DCTV commands", @bot.dctv_commands_enabled)
      when "all"
        @bot.cleverbot_enabled = toggle_command_set(m, "Cleverbot interfaces", @bot.cleverbot_enabled)
        @bot.dctv_commands_enabled = toggle_command_set(m, "DCTV commands", @bot.dctv_commands_enabled)
      else
        failed = true
      end

      m.user.notice "Sorry, I don't know how to turn #{group} #{action}" if failed
    end

    private

      def toggle_command_set(m, command_set_name, command_boolean_variable)
        if @turn_off
          if command_boolean_variable
            m.user.notice "#{command_set_name} have been disabled"
          else
            m.user.notice "#{command_set_name} are already disabled"
          end
          return false
        else
          if command_boolean_variable
            m.user.notice "#{command_set_name} are already enabled"
          else
            m.user.notice "#{command_set_name} have been enabled"
          end
          return true
        end
      end
  end

end
