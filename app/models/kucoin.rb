# working with kucoin market
class Kucoin
  HOST = 'https://api.kucoin.com'.freeze

  def buy(pair, amount)
    make_order(kucoin_pair_representation(pair), 'buy', amount)
  end

  def sell(pair, amount)
    make_order(kucoin_pair_representation(pair), 'sell', amount)
  end

  def withdraw(coin, amount, address)
    endpoint = "/v1/account/#{coin}/withdraw/apply"
    payload = { amount: amount, address: address }
    HTTParty.post(
      "#{HOST}#{endpoint}",
      query: payload,
      headers: headers(endpoint, payload)
    )
  end

  def deposit_address(coin)
    endpoint = "/v1/account/#{coin.upcase}/wallet/address"
    HTTParty.get(
      "#{HOST}#{endpoint}",
      headers: headers(endpoint)
    )['data']['address']
  end

  def prices
    HTTParty.get("#{HOST}/v1/open/tick")
            .parsed_response['data']
            .map do |pair|
              [pair['symbol'].delete('-'), pair['lastDealPrice']]
            end.to_h
  end

  def price(pair, direction)
    kucoin_pair = kucoin_pair_representation(pair)
    HTTParty.get("#{HOST}/v1/#{kucoin_pair}/open/tick")['data'][direction]
  end

  def balance(coin)
    endpoint = "/v1/account/#{coin.upcase}/balance"
    HTTParty.get(
      "#{HOST}#{endpoint}",
      headers: headers(endpoint)
    )['data']['balance']
  end

  private

  def make_order(pair, type, amount)
    endpoint = '/v1/order'
    payload = { symbol: pair, type: type,
                amount: amount, price: price(pair, type) }
    HTTParty.post(
      "#{HOST}#{endpoint}",
      query: payload,
      headers: headers(endpoint, payload)
    )
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

  def kucoin_pair_representation(pair)
    (pair[-4] == '-' ? pair : pair.insert(-4, '-')).upcase
  end

  def api_key
    ENV['KUCOIN_API_KEY']
  end

  def api_secret
    ENV['KUCOIN_API_SECRET']
  end
end
