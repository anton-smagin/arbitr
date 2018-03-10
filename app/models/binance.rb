# working with binance market
class Binance
  HOST = 'https://api.binance.com'.freeze

  def buy(symbol, amount)
    make_order(binance_symbol_reprosintation(symbol), 'BUY', amount)
  end

  def sell(symbol, amount)
    make_order(binance_symbol_reprosintation(symbol), 'SELL', amount)
  end

  def prices
    public_get('/api/v3/ticker/price').parsed_response.map do |price|
      [price['symbol'], price['price'].to_f]
    end.to_h
  end

  def price(symbol, direction)
    direction = direction.casecmp('buy').zero? ? 'bidPrice' : 'askPrice'
    public_get('/api/v3/ticker/bookTicker', symbol:
      binance_symbol_reprosintation(symbol))[direction].to_f
  end

  def withdraw(coin, amount, address, name)
    post('/wapi/v3/withdraw.html', asset:
      coin.upcase, address: address, amount: amount, name: name)
  end

  def deposit_address(coin)
    get('/wapi/v3/depositAddress.html', asset: coin.upcase)['address']
  end

  def balance(coin)
    account_info['balances'].find do |balance|
      balance['asset'] == coin.upcase
    end['free'].to_f
  end

  def account_info
    get('/api/v3/account')
  end

  private

  def make_order(symbol, type, amount)
    post(
      '/api/v3/order',
      symbol: symbol,
      side: type,
      type: 'MARKET',
      quantity: amount
    )
  end

  def public_get(endpoint, payload = {})
    HTTParty.get( "#{HOST}#{endpoint}", query: payload)
  end

  def get(endpoint, payload = {})
    HTTParty.get(
      "#{HOST}#{endpoint}",
      headers: headers,
      query: signed_params(payload)
    )
  end

  def post(endpoint, payload = {})
    HTTParty.post(
      "#{HOST}#{endpoint}",
      headers: headers,
      query: signed_params(payload)
    )
  end

  def signed_params(payload = {})
    timestamped_params = { timestamp: timestamp, **payload }.sort.to_h
    query_string = URI.encode_www_form(timestamped_params)
    { **timestamped_params.sort.to_h, signature: signature(query_string) }
  end

  def timestamp
    (Time.now.to_i * 1000).to_s
  end

  def headers
    { 'X-MBX-APIKEY' => api_key }
  end

  def signature(query_string)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'), api_secret, query_string
    )
  end

  def binance_symbol_reprosintation(symbol)
    symbol.delete('_').delete('-').upcase
  end

  def api_key
    ENV['BINANCE_API_KEY']
  end

  def api_secret
    ENV['BINANCE_API_SECRET']
  end

  #send('public_get', '/api/v1/exchangeInfo').parsed_response['symbols'].find{|s| s['symbol'] == 'CTRBTC'}
end
