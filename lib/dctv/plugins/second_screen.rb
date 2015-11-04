require 'httparty'

module DCTV
  module Plugins

    class SecondScreen
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      set :help_msg, "!secs [on|off|clear|<url>] - Executes Second Screen command or sets to <url>. Automatically generates a pastebin of links sent to the second screen between on and off commands."

      enable_authentication
      match /secs (.+)/

      def initialize(*args)
        super
        @second_screen_list = Array.new
      end

      def execute(m, input)
        if input =~ /^http/ || input == "on" || input == "off" || input == "clear"
          response = HTTParty.get("http://diamondclub.tv/api/secondscreen.php?url=#{input}&pro=4938827&user=#{m.user.nick}")
          m.user.notice "Command Sent. Response: #{response}"
        else
          m.user.notice "Adding line \"#{input}\" to pastebin"
        end

        if input == "on" || input == "clear"
          @second_screen_list.clear
        elsif input == "off"
          return if @second_screen_list.empty?
          paste = ""
          @second_screen_list.each { |link| paste += "#{link}\n" }
          result = request_paste(paste)
          m.user.notice "Assembling Pastebin. Result: #{result.body}"
          @second_screen_list.clear
        else
          @second_screen_list << input
        end
      end

      private

      def request_paste(paste)
        url = URI.parse("http://pastebin.com/api/api_post.php")
        params = {
          "api_dev_key" => config[:pastebin_api_key],
          "api_option" => "paste", # Specifies creation
          "api_paste_code" => paste
        }
        Net::HTTP.post_form(url, params)
      end
    end

  end
end
