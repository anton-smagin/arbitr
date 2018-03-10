# class for working with blockchain wallet api
# demands npm blockchain-wallet-service
class BlockchainInfo
  BLOCKCHAIN_INFO_SERVICE = 'http://127.0.0.1:3001'.freeze

  def send_money(address, amount_in_satoshi)
    HTTParty.get(
      "#{BLOCKCHAIN_INFO_SERVICE}/merchant/#{login}/payment",
      query: {
        password: password,
        to: address,
        from: 0,
        amount: amount_in_satoshi - 1500,
        fee: 1000
      }
    )
  end

  def deposit_address
    ENV['BLOCKCHAIN_RECIEVE_ADDRESS']
  end

  def balance
    HTTParty.get(
      "#{BLOCKCHAIN_INFO_SERVICE}/merchant/#{login}/balance",
      query: {
        password: password
      }
    ).parsed_response['balance']
  end

  def login
    ENV['BLOCKCHAIN_WALLET_ID']
  end

  def password
    ENV['BLOCKCHAIN_PASSWORD']
  end
end
