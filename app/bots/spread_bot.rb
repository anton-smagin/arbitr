# Bot for spread trade
class SpreadBot < BaseBot
  CORRIDOR = 0.025
  MINIMUM_SPREAD = 0.2

  def run
    return retrade! if should_retrade?
    trade! if active_trade || signal == :flat
  end

  def retrade!
    if active_trade.status == 'buying'
      exchange.cancel_order(symbol, active_trade.buy_order_id)
      active_trade.update(status: 'buy_failed')
    elsif active_trade.status == 'selling'
      exchange.cancel_order(symbol, active_trade.sell_order_id)
      active_trade.update(status: 'sell_failed')
      sell_market!
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
        buy_price: symbol_price[:buy],
        buy_order_id: buy_order_id,
        sell_price: symbol_price[:sell],
        amount: amount,
        symbol: symbol
      )
    end
  end

  def should_retrade?
    return false unless %w[selling buying].include?(active_trade&.status)
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
    [symbol_price[:buy] * (1 - CORRIDOR), symbol_price[:sell] * (1 + CORRIDOR)]
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
      price: symbol_price[:buy],
      direction: 'buy',
      type: 'limit',
      amount: amount
    )
  end

  def buy_order
    %i[open partially_filled].include?(
        exchange.order_status(active_trade.buy_order_id, symbol)
      )
  end

  def sell_order
    %i[open partially_filled].include?(
      exchange.order_status(active_trade.sell_order_id, symbol)
    )
  end
end
