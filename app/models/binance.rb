# working with binance market
class Binance
  HOST = 'https://api.binance.com'.freeze
  def prices
    HTTParty.get("#{HOST}/api/v3/ticker/price")
            .parsed_response
            .map do |price|
      [price['symbol'], price['price'].to_f]
    end.to_h
  end

  def balance(coin)
    account_info['balances'].find{ |balance| balance['asset'] == coin }['free']
  end

  def account_info
    HTTParty.get(
      "#{HOST}/api/v3/account",
      headers: headers,
      query: signed_params
    )
  end

  private

  def signed_params(payload = {})
    timestamped_params = { 'timestamp' => timestamp, **payload }
    query_string = URI.encode_www_form(timestamped_params.sort.to_h)
    "#{query_string}&signature=#{signature(query_string)}"
  end

  def timestamp
    (Time.now.to_f * 1000).to_i.to_s
  end

  def headers
    { 'X-MBX-APIKEY' => api_key }
  end

  def signature(query_string)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'), api_secret, query_string
    )
  end

  def api_key
    ENV['BINANCE_API_KEY']
  end

  def api_secret
    ENV['BINANCE_API_SECRET']
  end
end
