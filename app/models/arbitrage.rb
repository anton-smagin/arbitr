class Arbitrage < ApplicationRecord
  MARKETS = %w[poloniex binance kucoin yobit livecoin].freeze
  SYMBOLS ||= MARKETS.inject([]) do |symbols, market|
    symbols = symbols + market.capitalize.constantize.new.symbols
  end.group_by(&:itself).select { |_, v| v.size > 1 }.keys

  has_one :purchase
  has_one :sale
  has_many :transactions
end
