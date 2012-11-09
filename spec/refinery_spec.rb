require 'spec_helper'

describe Refinery do
  context '#load' do
    it 'returns a Turbine Graph' do
      expect(Refinery.load).to be_a(Turbine::Graph)
    end
  end
end
