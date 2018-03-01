class ArbitrageController < ApplicationController
  def index
    @arbitrage = Arbitrage.call
  end
end
