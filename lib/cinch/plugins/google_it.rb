require 'google-search'

module Cinch
  module Plugins

    class GoogleIt
      include Cinch::Plugin

      set :plugin_name, "google"
      set :help_msg, "!google [mode] <term> - Returns top hit on google when searching for <term>. Optional [mode] can be one of blog, book, image, local, news, patent, or video."

      match /google (\w+)\s?(.*)/

      def execute(m, mode, query)
        if query.nil? || query.empty?
          query = mode
          mode = nil
        end
        query = "#{mode} #{query}" unless ["blog", "book", "image", "local", "news", "patent", "video"].include?(mode)
        case mode
        when "blog"
          search = Google::Search::Blog.new(:query => query, :api_key => config[:google_api_key])
        when "book"
          search = Google::Search::Book.new(:query => query, :api_key => config[:google_api_key])
        when "image"
          search = Google::Search::Image.new(:query => query, :api_key => config[:google_api_key])
        when "local"
          search = Google::Search::Local.new(:query => query, :api_key => config[:google_api_key])
        when "news"
          search = Google::Search::News.new(:query => query, :api_key => config[:google_api_key])
        when "patent"
          search = Google::Search::Patent.new(:query => query, :api_key => config[:google_api_key])
        when "video"
          search = Google::Search::Video.new(:query => query, :api_key => config[:google_api_key])
        else
          search = Google::Search::Web.new(:query => query, :api_key => config[:google_api_key])
        end
        result = search.all_items.first
        # TODO: check for missing title/uri
        m.reply "#{CGI.unescape_html(result.title)}\n#{result.uri}"
      end
    end

  end
end
