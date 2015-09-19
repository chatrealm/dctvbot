# Adapted from https://github.com/FlagRun/Zeta/blob/master/plugins/help.rb

module Cinch
  module Plugins

    class Help
      include Cinch::Plugin
      set(
        plugin_name: "Help",
        help: "Helps with help info.\nUsage: `!help <plugin name>`"
      )

      match /help (.+)$/i, method: :execute_help
      def execute_help(m, name)
        list = {}
        @bot.plugins.each { |p| list[p.class.plugin_name.downcase] = {name: p.class.plugin_name, help: p.class.help} };
        return m.user.notice("Help for \"#{name}\" could not be found.") unless list.has_key?(name.downcase)
        m.user.notice("Help for #{list[name.downcase][:name]}:\n#{list[name.downcase][:help]}")
      end

      match 'help', method: :execute_list
      def execute_list(m)
        list = []
        @bot.plugins.each { |p| list << p.class.plugin_name unless p.class.plugin_name.blank? || p.class.help.blank? };
        m.user.notice("#{list.size} plugins currently loaded for #{@bot.nick}:\n#{list.to_sentence}.\nTo view help for a plugin, use `!help <plugin name>`.")
      end
    end

  end
end
