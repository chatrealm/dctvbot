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

      #reinterpret
      def search(query)
        wolfram = WolframAlpha::Client.new(
          config[:wolfram_api_key],
          options = {
            format: 'plaintext',
            ignorecase: true,
            reinterpret: true
        })
        response = wolfram.query(query)
        input = response["Input"] # Get the input interpretation pod.
        result = response.find { |pod| pod.title == "Result" }
        result = response.pods[1] unless result
        output = ""
        if result
          result.subpods.each do |subpod|
            output += subpod.plaintext
          end
          reply = "#{input.subpods[0].plaintext}\n"
          reply += Cinch::Toolbox.truncate(output.strip, @max_length).gsub("  ", ", ")
        else
          reply = "Sorry, I've no idea. Does this help?"
        end
        reply += " https://www.wolframalpha.com/input/?i=#{query.gsub(" ","+")}"
      end
    end

  end
end
