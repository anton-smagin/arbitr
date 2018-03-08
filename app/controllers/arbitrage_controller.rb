class ArbitrageController < ApplicationController
  def index
    @arbitrage = ArbitrageOpportunity.call
  end
end
