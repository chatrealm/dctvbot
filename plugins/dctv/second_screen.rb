# encoding: utf-8

require 'net/http'

module Plugins
  module DCTV

    class SecondScreen
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      enable_authentication

      match /secs (.+)/

      def execute(m, input)
        if input =~ /^http/ || input == "on" || input == "off" || input == "clear"
          response = HTTParty.get("http://diamondclub.tv/api/secondscreen.php?url=#{input}&pro=4938827&user=#{m.user.nick}")
          m.user.notice "Command Sent. Response: #{response}"
        else
          m.user.notice "Adding line \"#{input}\" to pastebin"
        end

        if input == "on"
          @bot.recorded_second_screen_list.clear
        elsif input == "off"
          return if @bot.recorded_second_screen_list.empty?

          paste = ""
          @bot.recorded_second_screen_list.each do |link|
            paste += "#{link}\n"
          end

          url = URI.parse("http://pastebin.com/api/api_post.php")
          params = {
            "api_dev_key" => config[:pastebin_api_key],
            "api_option" => "paste", # Specifies creation
            "api_paste_code" => paste
          }
          result = Net::HTTP.post_form(url, params)
          m.user.notice "Assembling Pastebin. Result: #{result.body}"
          @bot.recorded_second_screen_list.clear
        else
          @bot.recorded_second_screen_list << input unless input == "clear"
        end
      end
    end

  end
end
