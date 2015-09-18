# encoding: utf-8

class Watcher
  def initialize(bot)
    @bot = bot
  end

  def start
    x = 0
    while true
      @bot.handlers.dispatch :check_dctv
      if x % 30 == 0
        @bot.handlers.dispatch :check_twitter
        x = 0
      end
      x += 1
      sleep 10
    end
  end
end
