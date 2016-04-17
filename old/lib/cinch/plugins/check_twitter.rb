require 'twitter'

module Cinch
  module Plugins

    class CheckTwitter
      include Cinch::Plugin

      listen_to :check_twitter

      def initialize(*args)
        super
        @rate_time_cleared = Time.now
        @cleverbot = Cleverbot::Client.new
        begin
          @last_mention_id = @bot.twitter.mentions_timeline.first.id
        rescue Twitter::Error::TooManyRequests => error
          handle_too_many_requests(error)
        end
      end

      def listen(m)
        begin
          if Time.now < @rate_time_cleared
            @bot.debug("Twitter check waiting until #{@rate_time_cleared.to_s}")
            return
          end

          # Respond to @mentions
          @bot.twitter.mentions_timeline({ since_id: @last_mention_id }).each do |tweet|
            response = @cleverbot.write tweet.text.gsub(/@dctvbot/, '').gsub(/@/, '')
            @bot.twitter.update(". @#{tweet.user.screen_name} #{response}", { in_reply_to_status: tweet }) unless response.blank?
            @last_mention_id = tweet.id
          end

          auto_follow_back_girl
        rescue Twitter::Error::TooManyRequests => error
          handle_too_many_requests(error)
        end
      end

      private

      def auto_follow_back_girl
        follower_ids = Array.new
        @bot.twitter.follower_ids.each { |id| follower_ids << id }
        friend_ids = Array.new
        @bot.twitter.friend_ids.each { |id| friend_ids << id }
        new_followers = follower_ids - friend_ids
        @bot.twitter.follow new_followers if new_followers.any?
      end

      def handle_too_many_requests(error)
        @bot.debug error.message
        @rate_time_cleared = Time.now + error.rate_limit.reset_in.seconds + 1.second
        @bot.debug "Twitter check waiting until #{@rate_time_cleared.to_s}"
      end
    end

  end
end
