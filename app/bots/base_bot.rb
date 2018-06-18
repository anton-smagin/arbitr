# Base Bot abstract class
class BaseBot
  attr_reader :exchange, :symbol, :amount, :signal, :price

  def initialize(exchange, symbol, amount, price, signal)
    @exchange = exchange
    @symbol = symbol
    @amount = amount
    @signal = signal
    @price = price
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
end
