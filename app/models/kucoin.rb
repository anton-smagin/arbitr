# working with kucoin market
class Kucoin
  HOST = 'https://api.kucoin.com'.freeze

  def buy(symbol, amount)
    make_order(kucoin_symbol_representation(symbol), 'buy', amount)
  end

  def sell(symbol, amount)
    make_order(kucoin_symbol_representation(symbol), 'SELL', amount)
  end

  def withdraw(coin, amount, address)
    endpoint = "/v1/account/#{coin}/withdraw/apply"
    payload = { amount: amount, address: address }
    post(endpoint, query: payload, headers: headers(endpoint, payload))
  end

  def deposit_address(coin)
    endpoint = "/v1/account/#{coin.upcase}/wallet/address"
    get(endpoint, headers: headers(endpoint))['data']['address']
  end

  def prices
    get('/v1/open/tick').parsed_response['data'].map do |symbol|
      [symbol['symbol'].delete('-'), symbol['lastDealPrice']]
    end.to_h
  end

  def price(symbol, direction)
    kucoin_symbol = kucoin_symbol_representation(symbol)
    get("/v1/#{kucoin_symbol}/open/tick")['data'][direction.downcase]
  end

  def balance(coin)
    endpoint = "/v1/account/#{coin.upcase}/balance"
    get(endpoint, headers: headers(endpoint))['data']['balance']
  end

  private

  def make_order(symbol, type, amount)
    endpoint = '/v1/order'
    price = type.upcase == 'BUY' ? price(symbol, 'SELL') : price(symbol, 'BUY')
    payload = { symbol: symbol, type: type,
                amount: amount, price: price }
    post(endpoint, query: payload, headers: headers(endpoint, payload))
  end

  def headers(endpoint, payload = {})
    query_string = URI.encode_www_form(payload.sort.to_h)
    {
      'KC-API-KEY' => api_key,
      'KC-API-NONCE' => timestamp,
      'KC-API-SIGNATURE' => signature(endpoint, query_string),
      'Content-Type' => 'application/json'
    }
  end

  def signature(endpoint, query_string)
    #  Arrange the parameters in ascending alphabetical order(lower cases first)
    string = "#{endpoint}/#{timestamp}/#{query_string}"
    base64 = Base64.strict_encode64(string)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), api_secret, base64)
  end

  def timestamp
    (Time.now.to_f * 1000).to_i.to_s
  end

  def kucoin_symbol_representation(symbol)
    symbol_dup = symbol.dup
    (symbol_dup[-4] == '-' ? symbol_dup : symbol_dup.insert(-4, '-')).upcase
  end

  def get(endpoint, params = {})
    HTTParty.get("#{HOST}#{endpoint}", params)
  end

  def post(endpoint, params = {})
    HTTParty.post("#{HOST}#{endpoint}", params)
  end

  def api_key
    ENV['KUCOIN_API_KEY']
  end

  def api_secret
    ENV['KUCOIN_API_SECRET']
  end
end
