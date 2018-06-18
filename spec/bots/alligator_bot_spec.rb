require 'rails_helper'

RSpec.describe AlligatorBot do
  let(:symbol) { 'ETHBTC' }
  let(:amount) { 0.5 }
  let(:signal) { { alligator: :buy, prev_alligator: :flat, adx: 31 } }
  let(:bot) { AlligatorBot.new(exchange, symbol, prices, signal) }
  let(:prices) { { buy: 0.1, sell: 0.2 } }
  let(:exchange) { double(title: 'Livecoin', make_order: true) }

  shared_examples 'does nothing' do
    it 'does nothing' do
      expect(bot).to_not receive(:buy_market!)
      bot.run
    end
  end

  shared_examples 'sells if active trade' do
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

  context 'buy signal' do
    it 'buys trade amount of coins' do
      expect(bot).to receive(:buy_market!) { 1 }
      bot.run
      expect(AlligatorTrade.last).to have_attributes(
        buy_price: 0.2,
        symbol: symbol,
        amount: AlligatorBot::TRADE_BTC_AMOUNT / prices[:sell]
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
    let(:signal) { { alligator: :flat, alligator_prev: :flat, adx: 30 } }

    include_examples 'does nothing'
    include_examples 'sells if active trade'
  end

  context 'a lot of active trades' do
    before do
      create_list(
        :alligator_trade, 5, status: 'buying', exchange: exchange.title
      )
    end
    include_examples 'does nothing'
  end

  context 'adx < 30' do
    let(:signal) { { alligator: :buy, alligator_prev: :flat, adx: 25 } }
    include_examples 'does nothing'
  end

  context 'prev alligator eq buy' do
    let(:signal) { { alligator: :buy, alligator_prev: :buy, adx: 31 } }
    include_examples 'does nothing'
  end
end
