# Bot for alligator trade
class AlligatorBot < BaseBot
  TRADE_BTC_AMOUNT = 0.0015
  def initialize(exchange, symbol, price, signal)
    @symbol = symbol
    @exchange = exchange
    amount =
      if active_trade
        active_trade.amount
      else
        TRADE_BTC_AMOUNT / price[:sell]
      end
    super(exchange, symbol, amount, price, signal)
  end

  def run
    if signal[:alligator] == :buy
      return if active_trade || trades_count > 3 || signal[:adx] < 30
      return if [:buy, nil].include?(signal[:prev_alligator])
      return unless buy_market!
      AlligatorTrade.create(
        amount: amount,
        symbol: symbol,
        exchange: exchange.title,
        buy_price: price[:sell],
        status: 'buying'
      )
    elsif active_trade
      return unless sell_market!
      active_trade.update(status: 'finished', sell_price: price[:buy])
    end
  end

  def trades_count
    AlligatorTrade.where(status: 'buying').count
  end

  def active_trade
    AlligatorTrade
      .find_by(symbol: symbol, exchange: exchange.title, status: 'buying')
  end
end
