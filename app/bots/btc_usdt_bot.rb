# Bot for BTCUSDT trading
class BtcUsdtBot < BaseBot
  MIN_BTC_LOT = 0.001
  TRADE_AMOUNT = 0.0025
  def initialize(exchange, price, signal)
    @symbol = 'BTCUSDT'
    @exchange = exchange
    amount =
      if signal[:alligator] == :sell
        TRADE_AMOUNT
      else
        exchange.balance('USDT') / price[:sell]
      end
    super(exchange, symbol, amount, price, signal)
  end

  def run
    if signal[:alligator] == :sell && active_trades.empty?
      return unless sell_market!
      AlligatorTrade.create amount: amount, symbol: symbol, exchange:
        exchange.title, buy_price: price[:buy], status: 'selling'
    elsif signal[:alligator] != :sell && active_trades.any?
      return unless buy_market!
      active_trades.update_all status: 'finished', sell_price: price[:sell]
    end
  end

  def active_trades
    AlligatorTrade
      .where(symbol: symbol, exchange: exchange.title, status: 'selling')
  end
end
