class ArbitrageStatisticMailer < ApplicationMailer
  def opportunity(arbitrage_statistic)
    @arbitrage_statistic = arbitrage_statistic
    mail(to: 'swagmir2@gmail.com', subject:
      "Возможность Арбитража #{arbitrage_statistic.id}")
  end
end
