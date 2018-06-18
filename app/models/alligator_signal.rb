class AlligatorSignal
  def self.call(ticks)
    averages = ticks.map { |tick| tick[:high] + tick[:low] / 2 }
    m_as = {
      fast: averages.smma((ticks.size - 4), 8),
      middle:  averages.smma((ticks.size - 6), 13),
      slow:  averages.smma((ticks.size - 9), 21)
    }
    if m_as[:fast] > m_as[:middle] && m_as[:middle] > m_as[:slow]
      :buy
    elsif m_as[:fast] < m_as[:middle] && m_as[:middle] < m_as[:slow]
      :sell
    else
      :flat
    end
  end
end
