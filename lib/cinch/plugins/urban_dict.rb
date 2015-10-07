require 'cinch/toolbox'

module Cinch
  module Plugins

    class UrbanDict
      include Cinch::Plugin

      match(/urban (.+)/)

      def initialize(*args)
        super
        @max_length = config[:max_length] || 300
      end

      def execute(m, query)
        m.reply search(query)
      end

      def search(query)
        url = "http://www.urbandictionary.com/define.php?term=#{CGI.escape(query)}"
        document = Nokogiri::HTML(open(url), nil, 'utf-8')
        word = CGI.unescape_html(document.css(".word").first.content.strip)
        definition = Cinch::Toolbox.truncate(CGI.unescape_html(document.css(".meaning").first.content.strip), @max_length)
        example = Cinch::Toolbox.truncate(CGI.unescape_html(document.css(".example").first.content.strip), @max_length)
        "#{word}: #{definition} - #{url}\nExample: #{example}"
      rescue
        "No results found - #{url}"
      end
    end

  end
end
