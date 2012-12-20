require 'spec_helper'

module Refinery
  describe Edge do
    let(:parent) { Node.new(:parent) }
    let(:child)  { Node.new(:child) }

    let(:edge)   { Edge.new(parent, child, :gas) }

    before do
      parent.connect_via(edge)
      child.connect_via(edge)
    end

    describe '#demand' do
      context 'when the parent node has demand' do
        before { parent.set(:expected_demand, 50.0) }

        context 'and the edge has a share' do
          before { edge.set(:share, 0.5) }

          it 'returns the demand supplied by the edge' do
            expect(edge.demand).to eql(25.0)
          end
        end

        context 'and the edge has no share' do
          before { edge.set(:share, nil) }

          it 'does not calculate the demand supplied by the edge' do
            expect(edge.demand).to be_nil
          end
        end

        context 'and the outbound slot has a custom share' do
          before do
            edge.set(:share, 0.5)
            parent.slots.out(:gas).set(:share, 0.2)
          end

          it 'reduces demand by the share' do
            expect(edge.demand).to eql(50.0 * 0.5 * 0.2)
          end
        end
      end

      context 'when the parent node does not have demand' do
        before { parent.set(:expected_demand, nil) }

        context 'and the edge has a share' do
          before { edge.set(:share, 0.5) }

          it 'does not calculate the demand supplied by the edge' do
            expect(edge.demand).to be_nil
          end
        end

        context 'and the edge has no share' do
          before { edge.set(:share, nil) }

          it 'does not calculate the demand supplied by the edge' do
            expect(edge.demand).to be_nil
          end
        end
      end
    end # demand

  end # Edge
end # Refinery
