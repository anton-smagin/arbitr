class BotBalance < ApplicationRecord

  def self.save_estimated
    create(
      livecoin: Livecoin.new.estimated_btc_balance,
      binance: Binance.new.estimated_btc_balance
    )
  end
end
