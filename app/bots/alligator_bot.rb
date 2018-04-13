# Bot for alligator trade
class AlligatorBot < BaseBot
  def run
    if signal == :buy
      return if active_trade || !buy_market!
      AlligatorTrade.create(
        amount: amount,
        symbol: symbol,
        exchange: exchange.title,
        buy_price: symbol_price[:sell],
        status: 'buying'
      )
    elsif active_trade
      return unless sell_market!
      active_trade.update(status: 'finished', sell_price: symbol_price[:buy])
    end
  end

  def active_trade
    AlligatorTrade
      .find_by(symbol: symbol, exchange: exchange.title, status: 'buying')
  end
end
