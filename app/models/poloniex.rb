class Poloniex
  def prices
    HTTParty.get('https://poloniex.com/public?command=returnTicker')
            .parsed_response
            .select { |k, _v| k.include?('BTC') && !k.include?('USDT') }
            .transform_keys! { |k| k[4..-1] << "BTC" }
            .map do |symbol, price|
              [symbol,
              { buy: price['highestBid'].to_f, sell: price['lowestAsk'].to_f }]
            end.to_h
  end
end
