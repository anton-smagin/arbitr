class Arbitrage
  def self.call
    new.tap do |arbitrage|
      statistic = arbitrage.kucoin_prices.each_with_object({}) do |(pair, price), result|
        result[pair] =
          {
            kucoin: price,
            binance: arbitrage.binance_prices[pair],
            diffrence: ((price / arbitrage.binance_prices[pair]) * 100.0 - 100.0).abs
          }
      end

      arbitrage.result = statistic.sort_by { |diff| diff[1][:diffrence] }.reverse.to_h
    end
  end

  attr_accessor :result

  def yobit_prices
    @yobit_prices ||= Yobit.new.prices
  end

  def binance_prices
    @binance_prices ||= Binance.new.prices
  end

  def kucoin_prices
    @kucoun_prices ||= begin
      pairs = binance_prices.keys
      Kucoin.new.prices.select do |pair, _price|
        pairs.include?(pair) && pair.include?('BTC')
      end
    end
  end
end
