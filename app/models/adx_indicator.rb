# ADX indicator
class AdxIndicator
  LENGTH = 14

  def self.call(ticks)
    new(ticks).adx.last
  end

  attr_reader :ticks

  def initialize(ticks)
    @ticks = ticks
  end

  def adx
    res = [dx.to(LENGTH - 1).sma]
    dx.from(LENGTH).each do |dx_val|
      res << (res.last * 13 + dx_val) / 14
    end
    res
  end

  def dx
    plus_dms_sum.map.with_index do |plus_dm, i|
      100 * (plus_dm - minus_dms_sum[i]).abs / (plus_dm + minus_dms_sum[i])
    end
  end

  def dms
    @dms ||= begin
      res = { plus_DMs: [], minus_DMs: [] }
      prev_tick = ticks[0]
      ticks.each do |tick|
        up_move = tick[:high] - prev_tick[:high]
        down_move = prev_tick[:low] - tick[:low]
        res[:plus_DMs] << (up_move > down_move && up_move > 0 ? up_move : 0)
        res[:minus_DMs] << (down_move > up_move && down_move > 0 ? down_move : 0)
        prev_tick = tick
      end
      res
    end
  end

  def plus_dms_sum
    res = []
    dms[:plus_DMs][1..-1].each_cons(LENGTH) { |con| res << con.sum }
    res
  end

  def minus_dms_sum
    res = [dms[:minus_DMs][1..LENGTH].sum]
    dms[:minus_DMs][LENGTH + 1..-1].each_with_index do |_, i|
      res << res.last - (res.last / 14.0) + dms[:minus_DMs][LENGTH + 1 + i]
    end
    res
  end

  def plus_DIs
    plus_dms_sum.map.with_index do |dm_plus, i|
      100 * (dm_plus / true_ranges_sum[i])
    end
  end

  def minus_DIs
    minus_dms_sum.map.with_index do |dm_plus, i|
      100 * (dm_plus / true_ranges_sum[i])
    end
  end

  def dis(dms)
    dms[-LENGTH..-1].map.with_index do |dm, index|
      binding.pry
      last_index = dms.size - LENGTH + index
      100 * dms[last_index - LENGTH..last_index].sum / true_ranges_sum[-LENGTH + index]
    end
  end

  def true_ranges
    @true_ranges ||= ticks.map.with_index do |tick, index|
      if index.zero?
        tick[:high] - tick[:low]
      else
        [
          tick[:high] - tick[:low],
          (tick[:high] - ticks[index - 1][:close]).abs,
          (tick[:low] - ticks[index - 1][:close]).abs
        ].max
      end
    end
  end

  def true_ranges_sum
    @true_ranes_sum ||= begin
      prev_atr = true_ranges[-LENGTH - 15...-LENGTH - 1].sum

      ticks[-LENGTH - 2..-1].map.with_index do |tick, index|
        unless index.zero?
          prev_atr =
            prev_atr - (prev_atr / 14.0) + true_ranges[ticks.size - LENGTH - 2 + index]
        end
        prev_atr
      end
    end
  end

  def avg_true_ranges
    prev_atr = true_ranges[LENGTH...-LENGTH].sma
    ticks[-LENGTH..-1].map.with_index do |_, index|
      unless index.zero?
        prev_atr =
          (prev_atr * (LENGTH - 1) + true_ranges[ticks.size - LENGTH + index]) / 14.0
      end
      prev_atr
    end
  end
end
