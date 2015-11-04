require 'cinch/toolbox'
require 'wolfram-alpha'

module Cinch
  module Plugins

    class Wolfram
      include Cinch::Plugin

      set :help_msg, "!wolfram <term> - Attempts to answer your <term> using Wolfram Alpha."

      match /wolfram (.+)/

      def initialize(*args)
        super
        @max_length = config[:max_length] || 300
      end

      def execute(m, query)
        m.reply search(query)
      end

      def search(query)
        wolfram = WolframAlpha::Client.new(
          config[:wolfram_api_key],
          options = {
            format: 'plaintext',
            ignorecase: true,
            reinterpret: true
        })
        reply = format_reply(wolfram.query(query))
        reply += " https://www.wolframalpha.com/input/?i=#{query.gsub(" ","+")}"
      end

      def format_reply(response)
        result = response.find { |pod| pod.title == "Result" }
        result = response.pods[1] unless result
        if result
          output = ""
          result.subpods.each do |subpod|
            output += subpod.plaintext
          end
          output = output.strip.gsub("  ", ", ")
          reply = "#{response["Input"].subpods[0].plaintext}\n"
          reply += Cinch::Toolbox.truncate(output, @max_length)
          return reply
        end
        return "Sorry, I've no idea. Does this help?"
      end
    end

  end
end
