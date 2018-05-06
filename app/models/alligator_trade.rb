class AlligatorTrade < ApplicationRecord
  validates :status, inclusion: { in: %w[buying selling finished] }

  class << self
    def stats(exchange:, from:, to: Time.current)
      stats = stats_relation(exchange, from, to)
              .group('symbol')
              .select(
                "symbol, #{select_query_stats}"
              ).to_a.each_with_object({}) do |trade, result|
        result[trade.symbol] = stats_hash(trade)
      end
      stats['Total'] = total_stats(exchange, from, to)
      stats
    end

    def total_stats(exchange, from, to)
      total_stats = stats_relation(exchange, from, to)
                    .select(
                      select_query_stats
                    ).to_a[0]
      stats_hash(total_stats)
    end

    def stats_relation(exchange, from, to)
      where(exchange: exchange.capitalize)
        .where('created_at > ?', from)
        .where('updated_at < ?', to)
    end

    def stats_hash(trade)
      {
        wins: trade.wins,
        loses: trade.loses,
        max_profit: trade.max_profit&.round(2),
        max_lose: trade.max_lose&.round(2),
        avg_profit: trade.avg_profit&.round(2),
        current_status: trade.current_status > 0 ? 'buying' : 'finished'
      }
    end

    def select_query_stats
      'count(*) filter(where sell_price > buy_price) as wins,' \
        'count(*) filter(where sell_price <= buy_price) as loses,' \
        'max(sell_price / buy_price * 100 - 100) as max_profit, ' \
        'min(sell_price / buy_price * 100 - 100) as max_lose, ' \
        'avg(sell_price / buy_price * 100 - 100) as avg_profit, ' \
        "count(status) filter(where status in ('buying', 'selling')) as current_status"
    end
  end
end
