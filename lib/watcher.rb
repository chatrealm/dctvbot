class Watcher

  def initialize(bot, handler_symbol, sleep_seconds=10)
    @bot = bot
    @handler_symbol = handler_symbol
    @sleep_seconds = sleep_seconds
  end

  def start
    while true
      @bot.debug "Dispatching #{@hander_sumbol} handler..."
      @bot.handlers.dispatch @handler_symbol
      @bot.debug "Waiting #{@sleep_seconds} seconds before dispatching #{@handler_symbol} again."
      sleep @sleep_seconds
    end
  end

end
