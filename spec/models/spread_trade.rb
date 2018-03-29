require 'rails_helper'

RSpec.describe SpreadTrade, type: :model do
  should validate_inclusion_of(:status).
    in_array(%w(buying selling finished failed))
end
