class BotRunner
  INTERVAL = '1h'.freeze

  class << self
    def call
      new.run
    end

    def statistic
      @runner = new
      @runner.trade_symbols.map do |symbol|
        trade_amount =
          AlligatorBot::TRADE_BTC_AMOUNT / @runner.exchange.prices[symbol][:sell]
        [
          symbol,
          {
            trade_amount: trade_amount,
            signal: @runner.signal(symbol),
            balance: @runner.exchange.balances[symbol.sub('BTC', '')]
          }
        ]
      end.to_h
    end
  end

  def run
    alligator_symbols.each do |symbol|
      AlligatorBot.new(
        exchange,
        symbol,
        exchange.prices[symbol],
        signal(symbol)
      ).run
    end

    BtcUsdtBot.new(
      exchange,
      exchange.prices['BTCUSDT'],
      signal('BTCUSDT')
    ).run
  end

  def fetched_ticks
    @fetched_ticks ||= begin
      trade_symbols.map do |symbol|
        [
          symbol,
          Concurrent::Promise.new do
            exchange.ticks(symbol: symbol, interval: INTERVAL, limit: 80)
          end.execute
        ]
      end.to_h
    end
  end

  def exchange
    @exchange ||= Binance.new
  end

  def alligator_symbols
    trade_symbols - ['BTCUSDT']
  end

  def trade_symbols
    @trade_symbols ||= begin
      trading_symbols = exchange.symbols_info.select do |symbol|
        symbol['quoteVolume'].to_f > 1500 && symbol['symbol'][-3..-1] == 'BTC'
      end
      trading_symbols = trading_symbols.map { |s| s['symbol'] }
      [*current_trade_symbols, *trading_symbols, 'BTCUSDT'].uniq
    end
  end

  def current_trade_symbols
    AlligatorTrade.distinct('symbol').where(status: 'buying').pluck('symbol')
  end

  def signal(symbol)
    ticks = fetched_ticks[symbol].value
    return {} if ticks.size < 80
    {
      prev_alligator: AlligatorSignal.call(ticks[0...-1]),
      alligator: AlligatorSignal.call(ticks),
      adx: AdxIndicator.call(ticks)
    }
  end

  def last_signals(num, symbol)
    result = {}
    ticks = binance_exchange
            .ticks(symbol: symbol, interval: INTERVAL, limit: num + 50)
    ticks[50..-1].each_with_index do |_t, i|
      result[ticks[i + 50][:close_time]] =
        [
          AlligatorSignal.call(ticks[i..i + 50]),
          AdxIndicator.call(ticks[i..i + 50])
        ]
    end
    result
  end
end
