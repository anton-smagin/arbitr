# Binance exchange for strategy testing
class VirtualBinance < Binance
  def make_order(params={})
    true
  end

  def title
    'Virtual Binance'
  end
end
