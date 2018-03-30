# working with livecoin market
class Livecoin
  HOST = 'https://api.livecoin.net'.freeze
  MINIMUM_ORDER = 0.0001

  def prices
    @prices ||= begin
      btc_pairs =
        public_get('/exchange/ticker')
        .parsed_response
        .select { |pair| pair['symbol'][-3..-1] == 'BTC' }
        .map do |pair|
          [pair['symbol'], { buy: pair['best_bid'], sell: pair['best_ask'] }]
        end.to_h
      btc_pairs.transform_keys! { |key| key.sub('/', '') }
               .select { |(k, _)| symbols.include?(k) }
    end
  end

  def price(symbol, direction)
    prices[symbol][direction.to_sym]
  end

  def make_order(symbol:, amount:, direction:, type:, price: nil)
    if type == 'limit'
      limit_order(symbol, amount, direction, price)
    elsif type == 'market'
      market_order(symbol, amount, direction)
    end
  end

  def limit_order(symbol, amount, direction, price)
    order = post "/exchange/#{direction}limit", currencyPair: livecoin_symbol_reprosintation(symbol),
    price: price_to_precision(price, symbol).to_d, quantity: amount.to_d
    order['success'] ? order['orderId'] : false
  end

  def market_order(symbol, amount, direction)
    order = post "/exchange/#{direction}market", currencyPair: livecoin_symbol_reprosintation(symbol), quantity:
      amount.to_d
    order['success'] ? order['orderId'] : false
  end

  def cancel_order(symbol, order_id)
    symbol = livecoin_symbol_reprosintation(symbol)
    post '/exchange/cancellimit', currencyPair: symbol, orderId: order_id
  end

  def active_orders(symbol)
    get('/exchange/client_orders')
  end

  def order(order_id)
    get('/exchange/order', orderId: order_id)
  end

  def orders(payload = {})
    get('/exchange/client_orders', payload)
  end

  def symbols
    @symbols ||= coins_info.select { |coin| coin['walletStatus'] == 'normal' }
                           .map { |coin| coin['symbol'] << 'BTC' } - ['BTCBTC']
  end

  def coins_info
    @coins_info ||= public_get('/info/coinInfo').parsed_response['info']
  end

  def coin_info(coin)
    coin = coin.sub('BTC', '') if coin[-3..-1] == 'BTC'
    coins_info.find { |info| info['symbol'].casecmp(coin).zero? }
  end

  def balance(coin)
    get('/payment/balances', currency: coin)
  end

  def min_order(coin)
    restrictions(coin)[:minimum]
  end

  def restrictions(pair)
    @restrictions ||= public_get('/exchange/restrictions')['restrictions']
                      .map do |info|
                        [
                          info['currencyPair'].sub('/', ''),
                          {
                            minimum: info['minLimitQuantity'],
                            price_scale: info['priceScale']
                          }
                        ]
                      end.to_h[pair]
  end

  def price_to_precision(price, symbol)
    price.round(restrictions(symbol)[:price_scale])
  end

  def livecoin_symbol_reprosintation(symbol)
    clone_symbol = symbol
    clone_symbol.gsub(/_|-/, '').insert(-4, '/')
  end

  def headers(payload)
    { 'Api-Key' => api_key,
      'Sign' => signature(payload) }
  end

  def get(endpoint, payload = {})
    response = HTTParty.get(
      "#{HOST}#{endpoint}",
      query: payload,
      headers: headers(payload)
    )
  end

  def post(endpoint, payload = {})
    HTTParty.post(
      "#{HOST}#{endpoint}",
      body: payload,
      headers: headers(payload)
    )
  end

  def public_get(endpoint, payload = {})
    response = HTTParty.get("#{HOST}#{endpoint}", query: payload)
  end

  def signature(payload)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      api_secret,
      payload.sort.to_h.to_query
    ).upcase
  end

  def withdraw
    #not implimented yet
  end

  def deposit_address
    #not implimented yet
  end

  def title
    'Livecoin'
  end

  def commission
    0.0018
  end

  def api_key
    ENV['LIVECOIN_API_KEY']
  end

  def api_secret
    ENV['LIVECOIN_API_SECRET']
  end
end
