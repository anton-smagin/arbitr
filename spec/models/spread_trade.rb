require 'rails_helper'

RSpec.describe SpreadTrade, type: :model do
  it do
    should validate_inclusion_of(:status)
      .in_array(%w[buying selling finished buy_failed sell_failed])
  end

  let (:exchange) { 'Binance' }

  it '#wins' do
    create(:spread_trade, exchange: exchange, status: 'finished')
    expect(SpreadTrade.wins(exchange: exchange, from: 10.seconds.ago))
      .to eq 1
    expect(SpreadTrade.loses(exchange: exchange, from: 10.seconds.ago))
      .to eq 0
  end

  it '#loses' do
    create(:spread_trade, exchange: exchange, status: 'sell_failed')
    expect(SpreadTrade.wins(exchange: exchange, from: 10.seconds.ago))
      .to eq 0
    expect(SpreadTrade.loses(exchange: exchange, from: 10.seconds.ago))
      .to eq 1
  end
end
