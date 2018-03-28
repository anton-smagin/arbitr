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

  def make_order(symbol:, amount:, direction:, type:, price: nil)
    symbol = livecoin_symbol_reprosintation(symbol)
    if type == 'limit'
      limit_order(symbol, amount, direction, price)
    elsif type == 'market'
      market_order(symbol, amount, direction)
    end
  end

  def limit_order(symbol, amount, direction, price)
    post "/exchange/#{direction}limit", currencyPair: symbol, price:
      price.to_d, quantity: amount.to_d
  end

  def market_order(symbol, amount, direction)
    post "/exchange/#{direction}market", currencyPair: symbol, quantity:
      amount.to_d
  end

  def cancel_order(symbol, order_id)
    symbol = livecoin_symbol_reprosintation(symbol)
    post '/exchange/cancellimit', currencyPair: symbol, orderId: order_id
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
    clone_symbol.gsub(/_|-/, '').insert('/', -4)
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
    return response if response['success']
    raise ApiError, response
  end

  def post(endpoint, payload = {})
    response = HTTParty.post(
      "#{HOST}#{endpoint}",
      query: payload,
      headers: headers(payload)
    )
    return response if response['success']
    raise ApiError, response
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

  def api_key
    ENV['LIVECOIN_API_KEY']
  end

  def api_secret
    ENV['LIVECOIN_API_SECRET']
  end
end
