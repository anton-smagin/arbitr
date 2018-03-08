class Arbitrage < ApplicationRecord
  has_one :purchase
  has_one :sale
  has_many :transactions
end
