class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }

  class << self
    def stats(exchange:, from:, to: Time.current)
      where(
        exchange: exchange.capitalize,
        status: %w[sell_failed finished]
      ).where('created_at > ?', from)
        .where('updated_at < ?', to)
        .group('symbol', 'status').count
        .each_with_object({}) do |(group, count), result|
          result[group[0]] ||= { wins: 0, loses: 0 }
          result[group[0]][:wins] = count if group[1] == 'finished'
          result[group[0]][:loses] = count if group[1] == 'sell_failed'
        end
    end
  end
end
