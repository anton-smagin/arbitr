require 'rails_helper'
require 'shared_example_for_market'

RSpec.describe Binance do
  subject { Livecoin.new }
  it_behaves_like 'market'
end
