class BalanceController < ApplicationController
  helper_method :days
  def index
    @chart =
      BotBalance.where('created_at > ?', days.day.ago).map do |balance|
        [balance.created_at, balance.common]
      end.to_h
    @binance_wins = SpreadTrade.binance_wins(from: days.day.ago)
    @livecoin_wins = SpreadTrade.livecoin_wins(from: days.day.ago)
    @binance_loses = SpreadTrade.binance_loses(from: days.day.ago)
    @livecoin_loses = SpreadTrade.livecoin_loses(from: days.day.ago)
  end

  def days
    params[:days].nil? ? 7 : params[:days].to_i
  end
end
