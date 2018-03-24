class Poloniex
  def prices
    HTTParty.get('https://poloniex.com/public?command=returnTicker')
            .parsed_response
            .select { |k, _| k.include?('BTC') && !k.include?('USDT') }
            .transform_keys! { |k| k[4..-1] << 'BTC' }
            .select { |k, _| symbols.include? k }
            .map do |symbol, price|
              [symbol,
               { buy: price['highestBid'].to_f, sell: price['lowestAsk'].to_f }]
            end.to_h
  end

  def symbols
    @symbols ||=
      HTTParty.get('https://poloniex.com/public?command=returnCurrencies')
              .parsed_response
              .select do |_k, v|
                v['disabled'].zero? && v['delisted'].zero? && v['frozen'].zero?
              end.transform_keys! { |k| "#{k}BTC" }.keys
  end
end
