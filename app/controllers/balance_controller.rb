class BalanceController < ApplicationController
  helper_method :days
  def index
    @chart =
      BotBalance.where('created_at > ?', days.day.ago).map do |balance|
        [balance.created_at, balance.common]
      end.to_h
    @estimated_balance = @chart.values.last.round(6)
    @balance_change =
      (@chart.values.last / @chart.values.first * 100 - 100).round(2)
    @binance_spread_stats =
      SpreadTrade.stats(exchange: 'Binance', from: days.day.ago)
    @binance_alligator_stats =
      AlligatorTrade.stats(exchange: 'Binance', from: days.day.ago)
    @binance_alligator_stats.each do |symbol, _|
      next if symbol == 'Total'
      @binance_alligator_stats[symbol][:current_signal] = alligator_signal(symbol)
    end
  end

  def alligator_signal(symbol)
    @bot_runner ||= BotRunner.new
    @bot_runner.alligator_signal(symbol)
  end

  def days
    params[:days].nil? ? 7 : params[:days].to_i
  end
end
