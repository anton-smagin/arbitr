require 'rails_helper'

RSpec.describe ArbitrageStatistic do
  describe '#collect' do
    it 'collect statistic' do
      stub_const(
        'ArbitrageOpportunity',
        lambda do
          double result:
            {
              'BCDBTC' => { 'poloniex_binance' => 40, 'yobit_poloniex' => 10 },
              'LTCBTC' => { 'yobit_binance' => 8, 'poloniex_binance' => 15 }
            }
        end
      )

      stub_const('Arbitrage::MARKETS', %w[poloniex binance yobit])

      expect(ArbitrageStatisticMailer).to receive(:opportunity).once do
        double(deliver_now: nil)
      end

      ArbitrageStatistic.collect
      result = ArbitrageStatistic.all.to_a
      expect(result.count).to eq 2
      expect(result[0]).to have_attributes(
        percent: 10.0,
        symbol: 'BCDBTC',
        first_market: 'yobit',
        second_market: 'poloniex'
      )
      expect(result[1]).to have_attributes(
        percent: 15.0,
        symbol: 'LTCBTC',
        first_market: 'poloniex',
        second_market: 'binance'
      )
    end
  end
end
