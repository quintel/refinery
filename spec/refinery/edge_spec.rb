require 'spec_helper'

module Refinery
  describe Edge do
    let(:parent) { Node.new(:parent) }
    let(:child)  { Node.new(:child) }
    let(:edge)   { parent.connect_to(child, :gas) }

    describe '#demand' do
      context 'when a demand has been set' do
        before { edge.set(:demand, 50.0) }

        it { expect(edge.demand).to eql(50.0) }
      end

      context 'when no demand is set' do
        it { expect(edge.demand).to be_nil }
      end
    end # demand

  end # Edge
end # Refinery
