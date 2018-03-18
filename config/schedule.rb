# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
set :output, { error: 'error.log', standard: 'cron.log' }
# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.minute do
  runner "ArbitrageStatistic.collect"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
