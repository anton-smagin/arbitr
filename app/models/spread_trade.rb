class SpreadTrade < ApplicationRecord
  validates :status, inclusion:
   { in: %w[buying selling finished sell_failed buy_failed] }
end
