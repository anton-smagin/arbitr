class ArbitrageOpportunity
  def self.call
    new.tap do |arb|
      statistic = arb.symbols.each_with_object({}) do |symbol, result|
        Arbitrage::MARKETS.each do |market|
          result[symbol] ||= {}
          result[symbol]["#{market}_buy"] = arb.send("#{market}_prices")[symbol].try(:[], :buy)
          result[symbol]["#{market}_sell"] = arb.send("#{market}_prices")[symbol].try(:[], :sell)
        end

        Arbitrage::MARKETS.each_with_index do |market1|
          (Arbitrage::MARKETS - [market1]).each do |market2|
            if result[symbol]["#{market1}_buy"].nil? || result[symbol]["#{market2}_buy"].nil?
              result[symbol]["#{market1}_#{market2}"] = nil
              result[symbol]["#{market2}_#{market1}"] = nil
            else
              result[symbol]["#{market1}_#{market2}"] =
                (result[symbol]["#{market2}_buy"] / result[symbol]["#{market1}_sell"] * 100.0 - 100.0).round(2)
              result[symbol]["#{market2}_#{market1}"] =
                 (result[symbol]["#{market1}_buy"] / result[symbol]["#{market2}_sell"] * 100.0 - 100.0).round(2)
            end
          end
        end
      end

      arb.result = statistic.sort_by do |diff|
        -diff[1].reject { |k, _| k['buy'] || k ['sell'] }.values.compact.max
      end.to_h
    end
  end

  attr_accessor :result

  def symbols
    @symbols ||= begin
      symbols = Arbitrage::MARKETS.inject([]) do |res, market|
        res + send("#{market}_prices").keys
      end
      symbols.group_by(&:itself).select { |_, v| v.size > 1 }.keys
    end
  end

  def poloniex_prices
    @poloniex_prices ||= Poloniex.new.prices
  end

  def binance_prices
    @binance_prices ||= Binance.new.prices
  end

  def kucoin_prices
    @kucoun_prices ||= Kucoin.new.prices
  end
end
