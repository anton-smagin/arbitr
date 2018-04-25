class AlligatorSignal
  def self.call(ticks)
    averages = ticks.map { |tick| tick.reduce(:+) / tick.size }
    m_as = {
      fast: averages.sma((ticks.size - 1), 5),
      middle:  averages.sma((ticks.size - 3), 8),
      slow:  averages.sma((ticks.size - 6), 13)
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
