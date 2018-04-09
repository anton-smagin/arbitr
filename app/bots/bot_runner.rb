class BotRunner
  def self.call
    exchange = Livecoin.new
    # SpreadBot.new(exchange, 'XEMBTC', 10).run
    # SpreadBot.new(exchange, 'DASHBTC', 0.01).run
    SpreadBot.new(Binance.new, 'IOSTBTC', 400).run
  end
end
