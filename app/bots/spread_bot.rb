# Bot for spread trade
class SpreadBot
  CORRIDOR = 0.025

  attr_reader :exchange, :symbol, :amount

  def initialize(exchange, symbol, amount)
    @exchange = exchange
    @symbol = symbol
    @amount = amount
  end

  def run
    return if SpreadTrade.where(status: %w[finished failed], exchange: exchange.title, symbol: symbol).count > 10
    return if spread_difference < exchange.commission * 2
    return retrade! if should_retrade?
    trade!
  end

  def retrade!
    active_trade.update(status: 'failed')
    if active_trade.status == 'buying'
      cancel_order(active_trade.buy_order_id)
    elsif active_trade.status == 'selling'
      cancel_order(active_trade.sell_order_id)
    end
    @active_trade = nil
    trade!
  end

  def trade!
    if !active_trade
      buy_order_id = buy!
      if buy_order_id
        SpreadTrade.create(
          exchange: exchange.title,
          status: 'buying',
          buy_price: price[:buy],
          buy_order_id: buy_order_id,
          sell_price: price[:sell],
          buy_amount: amount,
          symbol: symbol
        )
      end
    elsif active_trade.status == 'buying' && !buy_order
      sell_order_id = sell!
      if sell_order_id
        active_trade.update(status: 'selling', sell_order_id: sell_order_id)
      end
    elsif active_trade.status == 'selling' && !sell_order
      active_trade.update(status: 'finished')
    end
  end

  def price
    @price ||= exchange.prices[symbol]
  end

  def should_retrade?
    return false unless %w[selling buying].include? active_trade&.status
    price_not_in_corridor?
  end

  def price_not_in_corridor?
    trading_price = if active_trade.status == 'selling'
                      active_trade[:sell_price]
                    elsif active_trade.status == 'buying'
                      active_trade[:buy_price]
                    end
    !trading_price.between?(*corridor)
  end

  def corridor
    [price[:buy] * (1 - CORRIDOR), price[:sell] * (1 + CORRIDOR)]
  end

  def symbol_price
    exchange.prices[symbol]
  end

  def spread_difference
    symbol_price[:sell] / symbol_price[:buy] * 100 - 100
  end

  def active_trade
    @active_trade ||=
      SpreadTrade.find_by(
        status: %w[buying selling],
        exchange: exchange.title,
        symbol: symbol
      )
  end

  def sell!
    exchange.make_order(
      symbol: symbol,
      price: active_trade.sell_price,
      direction: 'sell',
      type: 'limit',
      amount: amount
    )
  end

  def buy!
    exchange.make_order(
      symbol: symbol,
      price: price[:buy],
      direction: 'buy',
      type: 'limit',
      amount: amount
    )
  end

  def buy_order
    exchange.order(active_trade.buy_order_id)['status'] != 'EXECUTED'
  end

  def sell_order
    exchange.order(active_trade.sell_order_id)['status'] != 'EXECUTED'
  end
end