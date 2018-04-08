class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }

  class << self
    def wins(exchange:, from:,to: Time.current)
      where('created_at > ?', from)
        .where('updated_at < ?', to)
        .where(status: 'finished', exchange: exchange.capitalize)
        .count
    end

    def loses(exchange:, from:,to: Time.current)
        where('created_at > ?', from)
          .where('updated_at < ?', to)
          .where(status: 'sell_failed', exchange: exchange.capitalize)
          .count
    end
  end
end
