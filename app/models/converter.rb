class Converter
  def self.call(market, symbol, direction)
    price = BigDecimal.new(market.price(symbol, direction).to_s)
    if direction.upcase == 'BUY'
      btc_balance = BigDecimal.new(market.balance('BTC').to_s)
      (btc_balance / price).to_f
    else
      coin_balance = BigDecimal.new(market.balance(symbol.gsub('BTC', '')).to_s)
      (coin_balance / price).to_f
    end
  end
end
