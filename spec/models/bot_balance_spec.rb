require 'rails_helper'

RSpec.describe BotBalance, type: :model do
  describe '#self.save_estimated' do
    it 'saves btc balance' do
      expect_any_instance_of(Binance).to receive(:estimated_btc_balance) { 1 }
      expect_any_instance_of(Livecoin).to receive(:estimated_btc_balance) { 1 }
      BotBalance.save_estimated
      expect(BotBalance.first).to have_attributes livecoin: 1, binance: 1
    end
  end
  describe '#change' do
    it 'counts change' do
      create(:bot_balance, livecoin: 0.1, binance: 0, created_at: 2.day.ago)
      create(:bot_balance, livecoin: 0.2, binance: 0)
      expect(BotBalance.change(from: 3.day.ago)).to eq 100
    end
  end
end
