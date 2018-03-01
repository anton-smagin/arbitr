class Arbitrage
  def self.call
    new.tap do |arbitrage|
      statistic = arbitrage.yobit_prices.each_with_object({}) do |(pair, price), result|
        result[pair] =
          {
            yobit: price,
            binance: arbitrage.binance_prices[pair],
            diffrence: ((price / arbitrage.binance_prices[pair]) * 100.0 - 100.0).abs
          }
      end

      arbitrage.result = statistic.sort_by{ |diff|  diff[1][:diffrence] }.to_h
    end
  end

  attr_accessor :result

  def yobit_prices
    @yobit_prices ||= Yobit.new.prices
  end

  def binance_prices
    @binance_prices ||= Binance.new.prices
  end
end
