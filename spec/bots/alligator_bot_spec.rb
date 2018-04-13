require 'rails_helper'

RSpec.describe AlligatorBot do
  let(:symbol) { 'ETHBTC' }
  let(:amount) { 0.5 }
  let(:signal) { :buy }
  let(:bot) { AlligatorBot.new(exchange, symbol, amount, signal) }
  let(:prices) do
    prices = {}
    prices[symbol] = { buy: 0.1, sell: 0.2 }
    prices
  end
  let(:exchange) do
    double(
      title: 'Livecoin',
      prices: prices,
      make_order: true
    )
  end

  context 'buy signal' do
    it 'buys' do
      expect(bot).to receive(:buy_market!) { 1 }
      bot.run
      expect(AlligatorTrade.last).to have_attributes(
        buy_price: 0.2,
        symbol: symbol,
        amount: amount
      )
    end

    it 'doesnt buy if has active trade' do
      create(
        :alligator_trade,
        symbol: symbol,
        exchange: exchange.title,
        status: 'buying'
      )
      expect(bot).to_not receive(:buy_market!)
      bot.run
    end
  end

  context 'flat signal' do
    let(:signal) { :flat }
    it 'does nothing' do
      expect(bot).to_not receive(:buy_market!)
      bot.run
      expect(AlligatorTrade.count).to eq 0
    end

    it 'sells if active trade' do
      create(
        :alligator_trade,
        symbol: symbol,
        exchange: exchange.title,
        status: 'buying'
      )
      expect(bot).to receive(:sell_market!) { 2 }
      bot.run
      expect(AlligatorTrade.last).to have_attributes(
        sell_price: 0.1,
        symbol: symbol,
        status: 'finished'
      )
    end
  end
end
