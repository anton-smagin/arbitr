class BotRunner
  def self.call
    exchange = Livecoin.new
    SpreadBot.new(exchange, 'XEMBTC', 10).run
    SpreadBot.new(exchange, 'WAVESBTC', 1).run
  end
end
