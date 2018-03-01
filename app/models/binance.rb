class Binance
  def prices
    HTTParty.get("https://api.binance.com/api/v3/ticker/price").parsed_response.map do |price|
      [price['symbol'], price['price'].to_f]
    end.to_h
  end
end
