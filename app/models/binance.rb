# working with binance market
# all assets at https://www.binance.com/assetWithdraw/getAllAsset.html
class Binance < Exchange
  HOST = 'https://api.binance.com'.freeze

  def buy(symbol:, amount:, price: nil, type:)
    make_order symbol: symbol, direction: 'BUY', amount: amount, price:
      price, type: type
  end

  def sell(symbol:, amount:, price: nil, type:)
    make_order symbol: symbol, direction: 'SELL', amount: amount, price:
      price, type: type
  end

  def prices
    @prices ||=
      symbols_info
      .select { |pair| %w[BTC SDT].include? pair['symbol'][-3..-1] }
      .map do |price|
        [price['symbol'],
         { buy: price['bidPrice'].to_f, sell: price['askPrice'].to_f }]
      end.to_h
  end

  def ticks(params = {})
    params[:endTime] = params.delete(:end_time).to_i * 1000 if params[:end_time]
    params[:startTime] = params.delete(:start_time).to_i * 1000 if params[:start_time]
    public_get('/api/v1/klines', params)
      .parsed_response
      .map do |tick|
        [[:open_time, Time.at(tick[0] / 1000)],
         [:close_time, Time.at(tick[6] / 1000)],
         [:open, tick[1].to_f],
         [:high, tick[2].to_f],
         [:low, tick[3].to_f],
         [:close, tick[4].to_f]].to_h
      end
  end

  def symbols
    prices.keys
  end

  def price(symbol, direction)
    direction = direction.casecmp('buy').zero? ? 'bidPrice' : 'askPrice'
    public_get('/api/v3/ticker/bookTicker', symbol:
      binance_symbol_representation(symbol))[direction].to_f
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

  def balances
    @balances ||=
      account_info['balances']
      .select { |bal| bal['free'].to_f > 0 || bal['locked'].to_f > 0 }
      .map { |bal| [bal['asset'], bal['free'].to_f + bal['locked'].to_f] }
      .to_h
  end

  def account_info
    @account_info ||= get('/api/v3/account')
  end

  def make_order(symbol:, amount:, direction:, type:, price: nil)
    payload = {
      symbol: binance_symbol_representation(symbol),
      side: direction.upcase,
      type: type.upcase,
      quantity: amount_to_precision(amount, symbol)
    }
    if price
      payload[:price] = price_to_precision(price, symbol).to_d
      payload[:timeInForce] = 'GTC'
    end
    response = post('/api/v3/order', payload)
    response['orderId'] || false
  end

  def cancel_order(symbol, order_id)
    delete(
      '/api/v3/order',
      symbol: binance_symbol_representation(symbol),
      orderId: order_id
    )['orderId'].present?
  end

  def active_orders
    get('/api/v3/openOrders')
  end

  def order(order_id, symbol)
    get('/api/v3/allOrders',
        symbol: binance_symbol_representation(symbol),
        orderId: order_id)[0]
  end

  def order_status(order_id, symbol = nil)
    statuses[order(order_id, symbol)['status']]
  end

  def orders(symbol)
    get('/api/v3/allOrders', symbol: binance_symbol_representation(symbol))
  end

  def signed_params(payload = {})
    timestamped_params = { timestamp: timestamp, **payload }.sort.to_h
    query_string = URI.encode_www_form(timestamped_params)
    { **timestamped_params.sort.to_h, signature: signature(query_string) }
  end

  def timestamp
    (Time.now.to_i * 1000).to_s
  end

  def headers(_payload = {})
    { 'X-MBX-APIKEY' => api_key }
  end

  def signature(query_string)
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'), api_secret, query_string
    )
  end

  def binance_symbol_representation(symbol)
    symbol.gsub(%r{_|-|\/}, '')
  end

  def api_key
    ENV['BINANCE_API_KEY']
  end

  def api_secret
    ENV['BINANCE_API_SECRET']
  end

  def exchange_info
    @exhange_info ||= public_get('/api/v1/exchangeInfo').parsed_response
  end

  def symbols_info
    @symbols_info ||= public_get('/api/v1/ticker/24hr').parsed_response
  end

  def amount_to_precision(amount, symbol)
    lot_size = exchange_info['symbols']
               .find { |s| s['symbol'] == symbol }['filters'][1]['stepSize']
    precision = (Math.log10(lot_size.to_f) * -1).to_i
    amount.to_d.round(precision, :down).to_f
  end

  def price_to_precision(price, symbol)
    symbol_info = exchange_info['symbols'].find { |s| s['symbol'] == symbol }
    price.round(symbol_info['quotePrecision'] - 1)
  end

  def minimum_lot(symbol)
    exchange_info['symbols']
      .find { |s| s['symbol'] == symbol }['filters'][2]['minNotional']
  end

  def commission
    0.001
  end

  def title
    'Binance'
  end

  def statuses
    {
      'FILLED' => :filled,
      'NEW' => :open,
      'CANCELED' => :canceled,
      'REJECTED' => :rejected,
      'EXPIRED' => :expired,
      'PENDING_CANCEL' => :pending_cancelled,
      'PARTIALLY_FILLED' => :partially_filled
    }
  end

  def test_data(end_interval, start_interval = 1)
    (start_interval..end_interval).to_a.map do |n|
      [
        "#{n} hours ago",
        symbols.map do |s|
          Concurrent::Promise.new do
            ticks = ticks symbol: s, interval: '1h', limit: 80, end_time:
              n.hours.ago
            {
              adx: AdxIndicator.call(ticks),
              alligator: AlligatorSignal.call(ticks),
              price: ticks.last[:close],
              symbol: s,
              time: ticks.last[:open_time],
              interval: '1h',
              market: 'Binance'
            }
          end.execute
        end
      ]
    end.to_h.transform_values { |v| v.map(&:value) }
  end
end
