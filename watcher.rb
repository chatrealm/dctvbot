# encoding: utf-8

class Watcher
  def initialize(bot)
    @bot = bot
  end

  def start
    while true
      @bot.handlers.dispatch :check_dctv
      sleep 10
    end
  end
end
