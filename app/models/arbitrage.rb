class Arbitrage < ApplicationRecord
  MARKETS = %w[poloniex binance kucoin].freeze
  has_one :purchase
  has_one :sale
  has_many :transactions
end
