require 'rails_helper'

RSpec.describe BtcUsdtBot do
  let(:signal) { :flat }
  let(:bot) { BtcUsdtBot.new(exchange, signal) }
  let(:prices) { { 'BTCUSDT' => { buy: 10_000, sell: 10_100 } } }
  let(:exchange) do
    double(title: 'Livecoin', prices: prices, make_order: true, balance: 0.1 )
  end

  shared_examples 'it does nothing' do
    it 'does nothing' do
      bot.run
      expect(bot).not_to receive(:sell_market!)
      expect(AlligatorTrade.count).to eq 0
    end
  end

  context 'flat signal' do
    include_examples 'it does nothing'

    context 'with active trade' do
      let(:exchange) do
        double(
          title: 'Livecoin',
          prices: prices,
          balance: BtcUsdtBot::MIN_BTC_LOT
        )
      end
      let!(:active_trades) do
        create_list(
          :alligator_trade, 3, amount: 1, symbol: 'BTCUSDT', status: 'selling'
        )
      end

      it 'buys if active trade' do
        expect(bot).to receive(:buy_market!) { 1 }
        bot.run
        expect(AlligatorTrade.where(status: 'finished').count).to eq 3
      end

      it 'has amount that equals expected btc amount' do
        expect(bot.amount).to(
          eq(BtcUsdtBot::MIN_BTC_LOT / prices['BTCUSDT'][:sell])
        )
      end
    end
  end

  context 'sell signal' do
    let(:signal) { :sell }

    it 'sells if sell signal' do
      expect(bot).to receive(:sell_market!) { 1 }
      bot.run
      expect(AlligatorTrade.where(status: 'selling').count).to eq(1)
    end

    it 'has BTC balance amount' do
      expect(bot.amount).to eq BtcUsdtBot::TRADE_AMOUNT
    end
  end
end
