class BotRunner
  INTERVAL = '1h'.freeze

  def self.call
    new.run
  end

  def run
    trade_symbols.each do |symbol, amount|
      symbol_signal = alligator_signal(symbol)
      SpreadBot.new(binance_exchange, symbol, amount, symbol_signal).run
      AlligatorBot.new(binance_exchange, symbol, amount, symbol_signal).run
    end
  end

  def binance_exchange
    @binance_exchange ||= Binance.new
  end

  def trade_symbols
    {
      'LSKBTC' => 1,
      'STEEMBTC' => 4.2,
      'AMBBTC' => 30,
      'PPTBTC' => 0.7,
      'SNMBTC' => 70
    }
  end

  def alligator_signal(symbol)
    ticks = binance_exchange
            .ticks(symbol: symbol, interval: INTERVAL, limit: 30)
            .map { |tick| [tick[:high], tick[:low]] }
    AlligatorSignal.call(ticks)
  end
end
