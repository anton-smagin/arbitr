require 'rails_helper'

RSpec.describe SpreadTrade, type: :model do
  it do
    should validate_inclusion_of(:status)
      .in_array(%w[buying selling finished buy_failed sell_failed])
  end

  let (:exchange) { 'Binance' }

  it '#stats' do
    create(
      :spread_trade,
      exchange: exchange,
      status: 'finished',
      symbol: 'LTCBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    create(
      :spread_trade,
      exchange: exchange,
      status: 'sell_failed',
      symbol: 'ETHBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    create(
      :spread_trade,
      exchange: exchange,
      status: 'selling',
      symbol: 'ETHBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    create(
      :spread_trade,
      exchange: exchange,
      status: 'buying',
      symbol: 'LTCBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    expect(SpreadTrade.stats(exchange: exchange, from: 10.seconds.ago))
      .to eq(
        {
         'LTCBTC' => { wins: 1, loses: 0, current_status: 'buying' },
         'ETHBTC' => { wins: 0, loses: 1, current_status: 'selling' },
         'Total' => { wins: 1, loses: 1, avg_spread: 10.0 }
         }
      )
  end
end
