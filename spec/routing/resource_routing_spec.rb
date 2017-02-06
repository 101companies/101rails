require 'rspec'

describe 'routing' do

  it "routes resource/ to #landing" do
    expect(:get => 'resource/').to route_to('resource#landing')
  end
end