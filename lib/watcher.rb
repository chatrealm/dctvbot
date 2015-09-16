class Watcher

  def initialize(bot, handler_symbol, sleep_seconds=10)
    @bot = bot
    @handler_symbol = handler_symbol
    @sleep_seconds = sleep_seconds
  end

  def start
    puts 'ping'
    while true
      @bot.handlers.dispatch @handler_symbol
      sleep @sleep_seconds
    end
  end

end
