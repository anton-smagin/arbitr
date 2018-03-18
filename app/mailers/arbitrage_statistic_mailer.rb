class ArbitrageStatisticMailer < ApplicationMailer
  def opportunity(arbitrage_statistics)
    @arbitrage_statistics = arbitrage_statistics
    mail(to: 'swagmir2@gmail.com', subject:
      'Возможность Арбитража')
  end
end
