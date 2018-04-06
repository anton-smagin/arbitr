class BotBalance < ApplicationRecord
  class << self
    def save_estimated
      create(
        livecoin: Livecoin.new.estimated_btc_balance,
        binance: Binance.new.estimated_btc_balance
      )
    end

    def change(from:, to: Time.current)
      first_balance =
        where('created_at > ?', from).order(:created_at).limit(1).first
      last_balance =
        where('created_at < ?', to).order(created_at: :desc).limit(1).first
        (last_balance.livecoin + last_balance.binance) /
          (first_balance.livecoin + first_balance.binance)  * 100.0 - 100
    end
  end

  def common
    livecoin + binance
  end
end
