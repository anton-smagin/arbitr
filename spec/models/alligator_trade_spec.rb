require 'rails_helper'

RSpec.describe AlligatorTrade, type: :model do
  it do
    should validate_inclusion_of(:status)
      .in_array(%w[buying finished selling])
  end

  let (:exchange) { 'Binance' }

  it '#stats' do
    create(
      :alligator_trade,
      exchange: exchange,
      status: 'finished',
      symbol: 'LTCBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    create(
      :alligator_trade,
      exchange: exchange,
      status: 'finished',
      symbol: 'ETHBTC',
      buy_price: 1,
      sell_price: 1.1
    )
    create(
      :alligator_trade,
      exchange: exchange,
      status: 'finished',
      symbol: 'ETHBTC',
      buy_price: 1,
      sell_price: 1
    )
    create(
      :alligator_trade,
      exchange: exchange,
      status: 'buying',
      symbol: 'ETHBTC',
      buy_price: 1,
      sell_price: nil
    )
    expect(AlligatorTrade.stats(exchange: exchange, from: 10.seconds.ago))
      .to eq(
        'LTCBTC' => { wins: 1, loses: 0, max_profit: 10.0, max_lose: 10.0, avg_profit: 10.0, current_status: 'finished' },
        'ETHBTC' => { wins: 1, loses: 1, max_profit: 10.0, max_lose: 0.0, avg_profit: 5.0, current_status: 'buying' },
        'Total' => { wins: 2, loses: 1, max_profit: 10.0, max_lose: 0.0, avg_profit: 6.67, current_status: 'buying' }
      )
  end
end
