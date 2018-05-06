class BotRunner
  INTERVAL = '1h'.freeze
  class << self
    def call
      new.run
    end

    def statistic
      @runner = new
      @runner.trade_symbols.map do |symbol, amount|
        [
          symbol,
          {
            trade_amount: amount,
            signal: @runner.alligator_signal(symbol),
            balance: @runner.binance_exchange.balances[symbol.sub('BTC', '')]
          }
        ]
      end.to_h
    end
  end

  def run
    btc_signal = alligator_signal('BTCUSDT')
    trade_symbols.each do |symbol, amount|
      symbol_signal = alligator_signal(symbol)
      SpreadBot.new(
        binance_exchange,
        symbol,
        amount,
        { symbol_signal: symbol_signal, btc_signal: btc_signal }
      ).run
      AlligatorBot.new(
        binance_exchange,
        symbol,
        amount,
        { symbol_signal: symbol_signal, btc_signal: btc_signal }
      ).run
    end
    BtcUsdtBot.new(
      binance_exchange,
      btc_signal
    ).run
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
      'SNMBTC' => 70,
      'CDTBTC' => 180
    }
  end

  def alligator_signal(symbol)
    ticks = binance_exchange
            .ticks(symbol: symbol, interval: INTERVAL, limit: 30)
            .map { |tick| [tick[:high], tick[:low]] }
    AlligatorSignal.call(ticks)
  end
end
