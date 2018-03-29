RSpec.shared_examples 'market' do
  it { is_expected.to respond_to :prices }
  it { is_expected.to respond_to :price }
  it { is_expected.to respond_to :balance }
  it { is_expected.to respond_to :withdraw }
  it { is_expected.to respond_to :deposit_address }
end
