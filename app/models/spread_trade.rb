class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }

  class << self
    def stats(exchange:, from:, to: Time.current)
      stats_relation(exchange, from, to)
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
    end

    def stats_relation(exchange, from, to)
      where(exchange: exchange.capitalize, status: %w[sell_failed finished])
        .where('created_at > ?', from)
        .where('updated_at < ?', to)
    end
  end
end
