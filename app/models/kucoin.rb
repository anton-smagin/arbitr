# working with kucoin market
class Kucoin
  HOST = 'https://api.kucoin.com'.freeze

  def prices
    HTTParty.get('https://api.kucoin.com/v1/open/tick')
            .parsed_response['data']
            .map do |pair|
              [pair['symbol'].delete('-'), pair['lastDealPrice']]
            end.to_h
  end

  def balance(coin)
    endpoint = "/v1/account/#{coin}/balance"
    HTTParty.get("#{HOST}#{endpoint}", headers: headers(endpoint))
  end

  private

  def headers(endpoint, query_string = '')
    {
     'KC-API-KEY' => api_key,
     'KC-API-NONCE' => nonce,
     'KC-API-SIGNATURE' => signature(endpoint)
    }
  end

  def signature(endpoint, query_string = '')
    #  Arrange the parameters in ascending alphabetical order(lower cases first)
    string = "#{endpoint}/#{nonce}/#{query_string}"
    base_64 = Base64.strict_encode64(string)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), api_secret, base_64)
  end

  def nonce
    (Time.now.to_f * 1000).to_i.to_s
  end

  def api_key
    ENV['KUCOIN_API_KEY']
  end

  def api_secret
    ENV['KUCOIN_API_SECRET']
  end
end
