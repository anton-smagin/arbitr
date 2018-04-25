require 'rails_helper'

RSpec.describe SpreadBot do
  let(:symbol) { 'ETHBTC' }
  let(:amount) { 0.5 }
  let(:signal) { :flat }
  let(:bot) { SpreadBot.new(exchange, symbol, amount, signal) }
  let(:prices) { exchange_prices(0.1, 0.11) }
  let(:exchange) do
    double(
      title: 'Livecoin',
      prices: prices
    )
  end

  def exchange_prices(buy, sell)
    prices = {}
    prices[symbol] = { buy: buy, sell: sell }
    prices
  end

  context 'no flat signal' do
    let(:signal) { :buy }
    it 'does nothing' do
      bot.run
      expect(SpreadTrade.count).to eq 0
    end

    let(:exchange) do
      double(
        title: 'Livecoin',
        prices: prices,
        active_trade: false
      )
    end

    it 'sells if has active trade' do
      create(
        :spread_trade,
        exchange: 'Livecoin',
        symbol: symbol,
        status: 'buying',
        buy_price: 0.1
      )
      expect(bot).to receive(:sell!) { 101 }
      expect(bot).to receive(:buy_order).twice { false }
      bot.run
      expect(SpreadTrade.last.status).to eq 'selling'
      expect(SpreadTrade.last.sell_order_id).to eq 101
    end
  end

  context 'spread less then min commission' do
    let(:prices) { exchange_prices(0.1, 0.10019) }

    it 'does nothing' do
      bot.run
      expect(SpreadTrade.count).to eq 0
    end
  end

  context 'no active spread trade' do
    let(:exchange) do
      double(
        title: 'Livecoin',
        prices: { 'ETHBTC' => { buy: 0.1, sell: 0.11 } },
        active_trade: false,
        commission: 0.017
      )
    end

    it 'buys and creates active spread trade if no trade' do
      expect(bot).to receive(:buy!) { 100 }
      bot.run
      expect(SpreadTrade.last).to have_attributes(
        exchange: 'Livecoin',
        status: 'buying',
        buy_order_id: 100,
        buy_price: 0.1,
        amount: amount,
        sell_price: 0.11
      )
    end
  end

  context 'has active buying spread trade' do
    let(:exchange) do
      double(
        title: 'Livecoin',
        prices:  exchange_prices(0.1, 0.11),
        active_trade: active_trade,
        commission: 0.017
      )
    end

    let(:active_trade) do
      create(
        :spread_trade,
        exchange: 'Livecoin',
        symbol: symbol,
        status: 'buying',
        buy_price: 0.1
      )
    end

    it 'does nothing if has active trade and buy order exists' do
      expect(bot).to_not receive(:sell!)
      expect(bot).to receive(:buy_order).twice { 100 }
      expect { bot.run }.to_not(change { active_trade.reload.status })
    end

    it 'sells if has active trade and buy order does not exist' do
      expect(bot).to receive(:sell!) { 100 }
      expect(bot).to receive(:buy_order).twice { false }
      bot.run
      expect(SpreadTrade.last.status).to eq 'selling'
    end
  end

  context 'has active selling spread trade' do
    let(:exchange) do
      double(
        title: 'Livecoin',
        prices:  exchange_prices(0.1, 0.11),
        active_trade: active_trade,
        commission: 0.017
      )
    end

    let(:active_trade) do
      create(
        :spread_trade,
        exchange: 'Livecoin',
        symbol: symbol,
        status: 'selling',
        sell_price: 0.11
      )
    end

    it 'does nothing if has active trade and sell order exists' do
      expect(bot).to receive(:sell_order).twice { 101 }
      expect { bot.run }.to_not(change { active_trade.reload.status })
    end

    it 'change active trade status to finished' do
      expect(bot).to receive(:sell_order).twice { false }
      expect do
        bot.run
      end.to(change { active_trade.reload.status }.to('finished'))
    end
  end

  context 'price out of corridor' do
    let(:exchange) do
      double(
        title: 'Livecoin',
        prices:  exchange_prices(0.2, 0.21),
        active_trade: active_trade,
        commission: 0.017,
        cancel_order: true
      )
    end
    context 'selling' do
      let(:active_trade) do
        create(
          :spread_trade,
          exchange: 'Livecoin',
          symbol: symbol,
          status: 'selling',
          sell_price: 0.11,
          buy_price: 0.1
        )
      end

      it 'retrade' do
        expect(bot).to receive(:buy!) { 100 }
        expect(bot).to receive(:sell_order) { true }
        expect(bot).to receive(:sell_market!) { 101 }
        bot.run
        expect(SpreadTrade.where(status: 'sell_failed').count).to eq 1
        expect(SpreadTrade.where(status: 'buying').count).to eq 1
      end

      it 'would not retrade if no sell order' do
        expect(bot).to receive(:sell_order).twice { false }
        expect(bot).not_to receive(:retrade!)
        bot.run
        expect(SpreadTrade.where(status: 'finished').count).to eq 1
      end
    end

    context 'buying' do
      let(:active_trade) do
        create(
          :spread_trade,
          exchange: 'Livecoin',
          symbol: symbol,
          status: 'buying',
          sell_price: 0.11,
          buy_price: 0.1
        )
      end

      it 'retrade' do
        expect(bot).to receive(:buy!) { 100 }
        expect(bot).to receive(:buy_order) { true }
        bot.run
        expect(SpreadTrade.where(status: 'buy_failed').count).to eq 1
        expect(SpreadTrade.where(status: 'buying').count).to eq 1
      end

      it 'would not retrade if no buy order' do
        expect(bot).to receive(:buy_order).twice { false }
        expect(bot).not_to receive(:retrade!)
        expect(bot).to receive(:sell!) { 100 }
        bot.run
        expect(SpreadTrade.where(status: 'selling').count).to eq 1
      end
    end
  end
end
