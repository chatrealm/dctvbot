module Cinch
  module Plugins

    class Halp
      include Cinch::Plugin

      match /h[ae]lp$/, method: :general_help_message
      def general_help_message(m)
        list = []
        @bot.plugins.each do |p|
          next if p.class.help.nil? || p.class.help.blank?
          list << p.class.plugin_name
        end
        m.user.notice "Currently loaded plugins for #{@bot.nick}: #{list.to_sentence}.\nTo view help for a plugin use !halp `<plugin name>`\nAdditional info: https://github.com/tinnvec/dctvbot"
      end

      match /h[ae]lp (.+)$/, method: :plugin_help_message
      def plugin_help_message(m, term)
        list = {}
        @bot.plugins.each do |p|
          next if p.class.help.nil? || p.class.help.blank?
          list[p.class.plugin_name.downcase] = {
            name: p.class.plugin_name,
            help: p.class.help
          }
        end
        if list.has_key?(term.downcase)
          m.user.notice "Help for #{Format(:bold, list[term.downcase][:name])}:\n#{list[term.downcase][:help]}"
        else
          m.user.notice "Help for \"#{term}\" could not be found."
        end
      end
    end

  end
end
