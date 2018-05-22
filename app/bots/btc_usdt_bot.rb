# Bot for BTCUSDT trading
class BtcUsdtBot < BaseBot
  MIN_BTC_LOT = 0.001
  TRADE_AMOUNT = 0.0025
  def initialize(exchange, signal)
    @symbol = 'BTCUSDT'
    @exchange = exchange
    amount =
      if signal == :sell
        TRADE_AMOUNT
      else
        exchange.balance('USDT') / exchange.prices[@symbol][:sell]
      end
    super(exchange, symbol, amount, signal)
  end

  def run
    if signal == :sell && active_trades.empty?
      return unless sell_market!
      AlligatorTrade.create amount: amount, symbol: symbol, exchange:
        exchange.title, buy_price: symbol_price[:buy], status: 'selling'
    elsif signal != :sell && active_trades.any?
      return unless buy_market!
      active_trades.update_all status: 'finished', sell_price:
        symbol_price[:sell]
    end
  end

  def active_trades
    AlligatorTrade
      .where(symbol: symbol, exchange: exchange.title, status: 'selling')
  end
end
