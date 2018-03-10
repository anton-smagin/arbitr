require 'rails_helper'

RSpec.describe ArbitrageStatistic do
  describe '#collect' do
    it 'collect statistic' do
      expect(ArbitrageOpportunity).to receive(:call) do
        double(result: {
          'BCDBTC' => { binance_first: 100, kucoin_first: 100 },
          'LTCBTC' => { binance_first: 1.2, kucoin_first: 2.3 }
        })
      end

      ArbitrageStatistic.collect
      result = ArbitrageStatistic.first
      expect(result.first_market).to eq('Kucoin')
      expect(result.percent).to eq(2.3)
      expect(result.symbol).to eq('LTCBTC')
    end
  end
end
