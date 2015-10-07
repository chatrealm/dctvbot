require 'cinch/toolbox'
require 'wolfram-alpha'

module Cinch
  module Plugins

    class Wolfram
      include Cinch::Plugin

      match(/wolfram (.+)/)

      def initialize(*args)
        super
        @max_length = config[:max_length] || 300
      end

      def execute(m, query)
        m.reply search(query)
      end

      def search(query)
        wolfram = WolframAlpha::Client.new(config[:wolfram_api_key], options = { :timeout => 30 })
        response = wolfram.query query
        input = response["Input"] # Get the input interpretation pod.
        # result = response.find { |pod| pod.title == "Result" }
        result = response.pods[1] # unless result
        output = ""
        if result
          result.subpods.each do |subpod|
            output += "#{subpod.plaintext} "
          end
          output = Cinch::Toolbox.truncate(output.strip, @max_length)
          reply = "#{input.subpods[0].plaintext}\n"
          reply += output.gsub("  ", " ][ ")
          reply += "\nMore Info: https://www.wolframalpha.com/input/?i=#{query.gsub(" ","+")}"
        else
          "Sorry, I've no idea. Does this help? https://www.wolframalpha.com/input/?i=#{query.gsub(" ","+")}"
        end
      end
    end

  end
end
