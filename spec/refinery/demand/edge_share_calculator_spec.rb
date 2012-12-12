require 'spec_helper'

module Refinery::Demand ; describe 'Share calculations' do
  let(:parent) { Turbine::Node.new(:parent) }
  let(:child)  { Turbine::Node.new(:child) }

  let(:edge)   { parent.connect_to(child, :gas) }
  let(:calc)   { EdgeShareCalculator.new(edge) }

  before do
    parent.set(:calculator, NodeDemandCalculator.new(parent))
    child.set(:calculator,  NodeDemandCalculator.new(child))
  end

  describe '#demand' do
    context 'when the parent node has demand' do
      before { parent.set(:expected_demand, 50.0) }

      context 'and the edge has a share' do
        before { edge.set(:share, 0.5) }

        it 'returns the demand supplied by the edge' do
          expect(calc.demand).to eql(25.0)
        end
      end

      context 'and the edge has no share' do
        before { edge.set(:share, nil) }

        it 'does not calculate the demand supplied by the edge' do
          expect(calc.demand).to be_nil
        end
      end
    end

    context 'when the parent node does not have demand' do
      before { parent.set(:expected_demand, nil) }

      context 'and the edge has a share' do
        before { edge.set(:share, 0.5) }

        it 'does not calculate the demand supplied by the edge' do
          expect(calc.demand).to be_nil
        end
      end

      context 'and the edge has no share' do
        before { edge.set(:share, nil) }

        it 'does not calculate the demand supplied by the edge' do
          expect(calc.demand).to be_nil
        end
      end
    end
  end # demand

  # --------------------------------------------------------------------------

  # Tests for the edge share calculations are included in the integration
  # tests directory.

end ; end # Refinery::Demand
