class Kucoin
  def prices
    HTTParty.get('https://api.kucoin.com/v1/open/tick')
            .parsed_response['data']
            .map do |pair|
              [pair['symbol'].delete('-'), pair['lastDealPrice']]
            end.to_h
  end
end
