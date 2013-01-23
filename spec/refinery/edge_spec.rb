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

    describe '#child_share' do
      let(:other) { Node.new(:other) }
      before      { other.connect_to(child, :gas) }

      context 'when a share has been set' do
        before { edge.set(:child_share, 0.5) }

        it 'returns the share' do
          expect(edge.child_share).to eql(0.5)
        end
      end

      context 'when the edge and child have demand' do
        before do
          edge.set(:demand, 200.0)
          child.set(:preset_demand, 500.0)
        end

        it 'calculates the share' do
          expect(edge.child_share).to eql(0.4)
        end
      end

      context 'when the edge has demand and the child does not' do
        before do
          edge.set(:demand, 200.0)
        end

        it 'does not calculate a share' do
          expect(edge.child_share).to be_nil
        end
      end

      context 'when the child has demand but the edge does not' do
        before do
          child.set(:preset_demand, 500.0)
        end

        it 'does not calculate a share' do
          expect(edge.child_share).to be_nil
        end
      end

      context 'and the edge is the only carrier supplier to the child' do
        before do
          other.disconnect_from(child, :gas)
          other.connect_to(child, :electricity)
        end

        it 'returns 1.0' do
          expect(edge.child_share).to eql(1.0)
        end
      end

      context 'and the edge has demand of zero' do
        before { edge.set(:demand, 0.0) }

        it 'returns 0.0' do
          expect(edge.child_share).to eql(0.0)
        end
      end

      context 'when the edge is one of many carrier suppliers to the child' do
        it 'does not calculate a share' do
          expect(edge.child_share).to be_nil
        end
      end
    end # child_share

    describe '#parent_share' do
      let(:other) { Node.new(:other) }
      before      { parent.connect_to(other, :gas) }

      context 'when an parent share has been set' do
        before { edge.set(:parent_share, 0.5) }

        it { expect(edge.parent_share).to eql(0.5) }
      end

      context 'when the edge and parent have demand' do
        before do
          edge.set(:demand, 200.0)
          parent.set(:expected_demand, 800.0)
        end

        it { expect(edge.parent_share).to eql(0.25) }
      end

      context 'when the edge has demand but parent does not' do
        before { edge.set(:demand, 200.0) }

        it { expect(edge.parent_share).to be_nil }
      end

      context 'when the parent has demand but the edge does not' do
        before { parent.set(:expected_demand, 800.0) }

        it { expect(edge.parent_share).to be_nil }
      end

      context 'and the edge is the only carrier receiver from the parent' do
        before do
          parent.disconnect_from(other, :gas)
          parent.connect_to(other, :electricity)
        end

        it { expect(edge.parent_share).to eql(1.0) }
      end

      context 'and the edge is one of many carrier receivers form the parent' do
        it { expect(edge.parent_share).to be_nil }
      end

      context 'and the edge has demand of zero' do
        before { edge.set(:demand, 0.0) }

        it { expect(edge.parent_share).to be_zero }
      end
    end # parent_share

  end # Edge
end # Refinery
