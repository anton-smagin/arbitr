class ArbitrageStatistic < ApplicationRecord
  def self.collect
    best_deal = ArbitrageOpportunity.call
                                    .result
                                    .reject { |symbol, _| symbol == 'BCDBTC' }
                                    .first
    new(symbol: best_deal[0]).tap do |statistic|
      if best_deal[1][:kucoin_first] >= best_deal[1][:binance_first]
        statistic.percent = best_deal[1][:kucoin_first]
        statistic.first_market = 'Kucoin'
      else
        statistic.percent = best_deal[1][:binance_first]
        statistic.first_market = 'Binance'
      end
      statistic.save
    end
  end
end
