# Base Bot abstract class
class BaseBot
  attr_reader :exchange, :symbol, :amount, :signal

  def initialize(exchange, symbol, amount, signal)
    @exchange = exchange
    @symbol = symbol
    @amount = amount
    @signal = signal
  end

  def sell_market!
    market_order 'sell'
  end

  def buy_market!
    market_order 'buy'
  end

  def market_order(direction)
    exchange.make_order(
      symbol: symbol,
      direction: direction,
      type: 'market',
      amount: amount
    )
  end

  def symbol_price
    @symbol_price ||= exchange.prices[symbol]
  end
end
