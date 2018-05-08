class Exchange
  def estimated_btc_balance
    balance_hash = balances
    btc_balance = balance_hash.delete('BTC')
    btc_balance + balance_hash.reduce(0) do |sum, n|
      if n[0] == 'USDT'
        sum +  n[1] / prices["BTC#{n[0]}"][:sell]
      else
        sum + prices["#{n[0]}BTC"][:buy] * n[1]
      end
    end.round(8)
  end

  def public_get(endpoint, payload = {})
    HTTParty.get("#{self.class::HOST}#{endpoint}", query: payload)
  end

  def signed_params(payload = {})
    payload
  end

  def get(endpoint, payload = {})
    HTTParty.get(
      "#{self.class::HOST}#{endpoint}",
      headers: headers(payload),
      query: signed_params(payload)
    )
  end

  def post(endpoint, payload = {})
    HTTParty.post(
      "#{self.class::HOST}#{endpoint}",
      headers: headers(payload),
      body: signed_params(payload)
    )
  end

  def delete(endpoint, payload = {})
    HTTParty.delete(
      "#{self.class::HOST}#{endpoint}",
      headers: headers(payload),
      body: signed_params(payload)
    )
  end
end
