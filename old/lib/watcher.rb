class Watcher

  def initialize(bot, handler_symbol, sleep_seconds=10)
    @bot = bot
    @handler_symbol = handler_symbol
    @sleep_seconds = sleep_seconds
  end

  def start
    while true
      @bot.handlers.dispatch @handler_symbol
      @bot.debug "#{@handler_symbol} handler dispatched, waiting #{@sleep_seconds} before dispatching again"
      sleep @sleep_seconds
    end
  end

end