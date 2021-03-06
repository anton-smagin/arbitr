# Bot for spread trade
class SpreadBot < BaseBot
  CORRIDOR = 0.03
  MINIMUM_SPREAD = 0.2

  def run
    return retrade! if should_retrade?
    trade! if active_trade || signal.values.uniq == [:flat]
  end

  def retrade!
    if active_trade.status == 'buying'
      if exchange.cancel_order(symbol, active_trade.buy_order_id)
        active_trade.update(status: 'buy_failed')
      end
    elsif active_trade.status == 'selling'
      if exchange.cancel_order(symbol, active_trade.sell_order_id)
        active_trade.update(
          status: 'sell_failed',
          sell_price: price[:buy]
        )
        sell_market!
      end
    end
    @active_trade = nil
    trade!
  end

  def trade!
    if !active_trade
      new_trade
    elsif active_trade.status == 'buying' && !buy_order
      sell_order_id = sell!
      if sell_order_id
        active_trade.update(status: 'selling', sell_order_id: sell_order_id)
      end
    elsif active_trade.status == 'selling' && !sell_order
      active_trade.update(status: 'finished')
    end
  end

  def new_trade
    return if spread_difference < MINIMUM_SPREAD
    if buy_order_id = buy!
      SpreadTrade.create(
        exchange: exchange.title,
        status: 'buying',
        buy_price: price[:buy],
        buy_order_id: buy_order_id,
        sell_price: price[:sell],
        amount: amount,
        symbol: symbol
      )
    end
  end

  def should_retrade?
    if active_trade&.status == 'buying' && buy_order ||
        active_trade&.status == 'selling' && sell_order
      !price_in_corridor?
    else
      false
    end
  end

  def price_in_corridor?
    trading_price = if active_trade.status == 'selling'
                      active_trade[:sell_price]
                    elsif active_trade.status == 'buying'
                      active_trade[:buy_price]
                    end
    trading_price.between?(*corridor)
  end

  def corridor
    [price[:buy] * (1 - CORRIDOR), price[:sell] * (1 + CORRIDOR)]
  end

  def spread_difference
    price[:sell] / price[:buy] * 100 - 100
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
    exchange.order_status(active_trade.buy_order_id, symbol) != :filled
  end

  def sell_order
    exchange.order_status(active_trade.sell_order_id, symbol) != :filled
  end
end
