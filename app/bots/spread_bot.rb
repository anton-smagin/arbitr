# Bot for spread trade
class SpreadBot
  CORRIDOR = 0.025

  def self.run(exchange, symbol)
    bot = new(exchange, symbol)
    return unless spread_diffrence < exchange.commission * 2
    return bot.retrade if bot.should_retrade?
    bot.trade
  end

  attr_reader :exchange, :symbol

  def initialize(exchange, symbol)
    @exchange = exchange
    @symbol = symbol
  end

  def retrade
    active_trade.update(status: 'failed')
    trade
  end

  def trade
    if !active_trade
      SpreadTrade.create(
        status: 'buying',
        buy_price: price[:buy],
        sell_price: price[:sell]
      ) if buy!(price[:buy])
    elsif active_trade.status == 'buying' && !buy_order
      active_trade.update(status: 'selling') if sell!(active_trade.sell_price)
    elsif active_trade.status == 'selling' && !sell_order
      active_trade.update(status: 'finished')
    end
  end

  def price
    @price ||= exchange.price[symbol]
  end

  def should_retrade?
    return false unless %w[selling buying].include? active_trade.&status
    price_not_in_corridor?
  end

  def price_not_in_corridor?
    trading_price = if active_trade.status == 'selling'
                      sell_order[:price]
                    elsif active_trade.status == 'buying'
                      buy_order[:price]
                    end
    !trading_price.between?(*corridor)
  end

  def corridor
    [price[:buy] * (1 - CORRIDOR), price[:sell] * (1 + CORRIDOR)]
  end

  def symbol_price
    exchage.prices[symbol]
  end

  def spread_difference
    symbol_price[:sell] / symbol_price[:buy] * 100 - 100
  end

  def active_trade
    @active_trade ||= SpreadTrade.find(status: %w[buying selling])
  end

  def sell!
    true
  end

  def buy!
    true
  end

  def buy_order
    exchange.active_orders(@symbol)
  end

  def sell_order
    exchange.active_orders(@symbol)
  end
end
