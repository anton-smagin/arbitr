class BotRunner
  def self.call
    exchange = Binance.new
    SpreadBot.new(exchange, 'LSKBTC', 1).run
    SpreadBot.new(exchange, 'BLZBTC', 25).run
    SpreadBot.new(exchange, 'STEEMBTC', 4.2).run
    SpreadBot.new(exchange, 'AMBBTC', 30).run
    SpreadBot.new(exchange, 'PPTBTC', 0.7).run
    SpreadBot.new(exchange, 'SNMBTC', 70).run
  end
end
