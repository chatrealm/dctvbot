require 'json'
require 'net/http'
require 'uri'

module Cinch
  module Plugins

    class StrawPoll
      include Cinch::Plugin
      include Cinch::Extensions::Authentication

      enable_authentication

      match(/(poll?)\s(.+)\|(.+)/)

      def execute(m, mode, title, options_string)
        options = options_string.split(",").collect { |o| o = o.strip }
        options << "pol pot" if mode == "pol"
        response = request_poll(title.strip, options)
        unless response['id'].nil?
          3.times do
            @bot.primary_channel.send "#{Format(:white, :blue, " VOTE ")} #{title.strip} https://strawpoll.me/#{response['id']}"
            sleep 60
          end
        else
          m.user.notice "Error: #{response['error']}"
        end
      end

      private

      def request_poll(title, options)
        uri = URI('https://strawpoll.me/api/v2/polls/')
        req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        req.body = { title: title, options: options, multi: false }.to_json
        @bot.debug "Request body: #{req.body}"
        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) { |http| http.request req }
        JSON.parse(res.body)
      end
    end

  end
end
