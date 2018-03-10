class ArbitrageOpportunity
  def self.call
    new.tap do |arbitrage|
      statistic = arbitrage.kucoin_prices.each_with_object({}) do |(pair, price), result|
        result[pair] =
          {
            kucoin_buy: price[:buy],
            kucoin_sell: price[:sell],
            binance_buy: arbitrage.binance_prices[pair][:buy],
            binance_sell: arbitrage.binance_prices[pair][:sell],
            kucoin_first: ((arbitrage.binance_prices[pair][:buy] / price[:sell]) * 100.0 - 100.0).round(2),
            binance_first: ((price[:buy] / arbitrage.binance_prices[pair][:sell]) * 100.0 - 100.0).round(2),
          }
      end

      arbitrage.result = statistic.sort_by do |diff|
        -[diff[1][:kucoin_first], diff[1][:binance_first]].max
      end.to_h
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
        pairs.include?(pair) && pair.include?('BTC') && !pair.include?('USDT')
      end
    end
  end
end
