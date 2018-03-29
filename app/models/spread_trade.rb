class SpreadTrade < ApplicationRecord
   validates :status, inclusion: { in: %w(buying selling finished failed) }
end
