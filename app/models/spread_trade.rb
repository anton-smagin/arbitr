class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }

  class << self
    def stats(exchange:, from:, to: Time.current)
      result = stats_relation(exchange, from, to)
        .group('status', 'symbol')
        .select('count(*) as count_all, status, symbol')
        .each_with_object({}) do |trade, result|
          result[trade.symbol] ||= { wins: 0, loses: 0 }
          if trade.status == 'finished'
            result[trade.symbol][:wins] = trade.count_all
          elsif trade.status == 'sell_failed'
            result[trade.symbol][:loses] = trade.count_all
          end
        end
      result['Total'] = total_stats(exchange, from, to)
      result
    end

    def stats_relation(exchange, from, to)
      where(exchange: exchange.capitalize, status: %w[sell_failed finished])
        .where('created_at > ?', from)
        .where('updated_at < ?', to)
    end

    def total_stats(exchange, from, to)
      stats = stats_relation(exchange, from, to)
              .group('status')
              .select(
                'count(*) as count_all, ' \
                'avg(sell_price / buy_price) * 100 - 100 as avg, status'
              ).to_a
      {
        wins: stats.find { |s| s.status == 'finished' }.count_all,
        loses: stats.find { |s| s.status == 'sell_failed' }.count_all,
        avg_spread: (stats.reduce(0) { |sum, stat| sum + stat.avg } / 2)&.round(2)
      }
    end
  end
end
