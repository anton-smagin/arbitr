task arbitrage_task: :environment do
  wallet = BlockchainInfo.new
  # Kucoin
  buyer = Kucoin.new
  seller = Binance.new

  symbol = 'CTRBTC'
  coin = 'CTR'

  wallet.send_money(buyer.deposit_address('BTC'), wallet.balance)

  while buyer.balance('BTC').zero?
    sleep(5)
  end

  buyer.buy(symbol, Converter.call(buyer, symbol, 'BUY'))

  while buyer.balance(coin).zero?
    sleep(5)
  end

  buyer.withdraw(coin, buyer.balance(coin), seller.deposit_address(coin))

  while seller.balance(coin).zero?
    sleep(5)
  end

  seller.sell(symbol, Converter.call(seller, symbol, 'SELL'))

  while seller.balance('BTC').zero?
    sleep(5)
  end

  seller.withdraw('BTC', wallet.deposit_address)
end
