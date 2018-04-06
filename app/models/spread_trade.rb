class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }

  class << self
    %w[livecoin binance].each do |exchange|
      define_method("#{exchange}_wins") do |params|
        params[:to] ||= Time.current
        SpreadTrade.where('created_at > ?', params[:from])
                   .where('updated_at < ?', params[:to])
                   .where(status: 'finished', exchange: exchange.capitalize)
                   .count
      end
      define_method("#{exchange}_loses") do |params|
        where('created_at > ?', params[:from])
          .where('updated_at < ?', params[:to])
          .where(status: 'sell_failed', exchange: exchange.capitalize)
          .count
      end
    end
  end
end
