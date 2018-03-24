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

    notify_statistics = statistics.reject do |s|
      ArbitrageStatistic.where(notified: true, symbol: s.symbol, first_market:
        s.first_market, second_market: s.second_market)
                        .where('created_at > ?', 1.day.ago).count > 0
    end

    return if notify_statistics.blank?
    ArbitrageStatistic.where(id: notify_statistics.pluck(:id))
                      .update_all(notified: true)
    ArbitrageStatisticMailer.opportunity(statistics).deliver_now
  end
end
