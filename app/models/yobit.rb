class Yobit
  def prices
    obtain_prices.map do |k, v|
      [k.upcase.delete('_'), { buy: v['buy'], sell: v['sell'] }]
    end.to_h
  end

  def obtain_prices
    pairs.map do |pairs_slice|
      JSON.parse(HTTParty.get("https://yobit.net/api/3/ticker/#{pairs_slice.join('-')}").body)
    end.reduce({}, :merge)
  end

  def pairs
    selected_symbols = symbols.select { |symbol| Arbitrage::SYMBOLS.include? symbol.delete('_').upcase }
    (0..selected_symbols.count).each_slice(60).map{ |slice| selected_symbols[slice[0]..slice[-1]] }
  end

  def symbols
    @symbols ||= JSON.parse(HTTParty.get('https://yobit.net/api/3/info'))['pairs'].keys
  end
end
