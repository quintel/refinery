require 'spec_helper'

module Refinery
  describe Edge do
    let(:parent) { Node.new(:parent) }
    let(:child)  { Node.new(:child) }
    let(:edge)   { parent.connect_to(child, :gas) }

    describe '#demand' do
      context 'when the child node has demand' do
        before { child.set(:preset_demand, 50.0) }

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

        context 'and the inbound slot has a custom share' do
          before do
            edge.set(:share, 0.5)
            child.slots.in(:gas).set(:share, 0.2)
          end

          it 'reduces demand by the share' do
            expect(edge.demand).to eql(50.0 * 0.5 * 0.2)
          end
        end
      end # when the child node has demand

      context 'when the child node does not have demand' do
        before { child.set(:preset_demand, nil) }

        context 'and the edge has a share' do
          before { edge.set(:share, 0.5) }

          it 'does not calculate the demand supplied by the edge' do
            expect(edge.demand).to be_nil
          end
        end

        context 'and the edge has an output share' do
          before { edge.set(:output_share, 0.5) }

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
      end # when the child node does not have demand

      context 'when the parent node has demand' do
        before { parent.set(:expected_demand, 100.0) }

        context 'and the edge has an output share' do
          before { edge.set(:output_share, 0.5) }

          it 'returns the demand supplied by the edge' do
            expect(edge.demand).to eql(50.0)
          end
        end # and the edge has an output share

        context 'and the outbound slot has a custom share' do
          before do
            edge.set(:output_share, 0.5)
            parent.slots.out(:gas).set(:share, 0.2)
          end

          it 'reduces the demand according to the slot share' do
            expect(edge.demand).to eql(10.0)
          end
        end

        context 'and the edge does not have an output share' do
          before { edge.set(:output_share, nil) }

          it 'does not calculate the demand supplied by the edge' do
            expect(edge.demand).to be_nil
          end
        end # and the edge does not have an output share
      end # when the parent node has demand
    end # demand

  end # Edge
end # Refinery
