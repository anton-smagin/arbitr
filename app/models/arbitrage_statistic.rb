class ArbitrageStatistic < ApplicationRecord
  def self.collect
    statistic = ArbitrageOpportunity.call
                                    .result

    deals = statistic.map do |symbol, prices|
      diffrence = prices.select do |key, val|
        key.split('_').all? { |e| Arbitrage::MARKETS.include?(e) }
      end
      opportunites = diffrence.select do |markets, diff|
        diff.kind_of?(Numeric) && diff.between?(9, 30)
      end
      [symbol, opportunites] unless opportunites.empty?
    end.compact.to_h

    statistics = deals.map do |symbol, diffrence|
      diffrence.map do |market, percent|
        market1, market2 = market.split('_')
        create(symbol: symbol, first_market: market1, second_market:
          market2, percent: percent)
      end
    end.flatten
    return if statistics.blank?
    ArbitrageStatisticMailer.opportunity(statistics).deliver_now
  end
end
