require 'rails_helper'

RSpec.describe SpreadBot do
  it 'buys' do
    expect(SpreadBot.new('', '').buy!).to be true
  end
end
