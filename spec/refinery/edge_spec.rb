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

    describe '#share' do
      let(:other) { Node.new(:other) }
      before      { other.connect_to(child, :gas) }

      context 'when a share has been set' do
        before { edge.set(:share, 0.5) }

        it 'returns the share' do
          expect(edge.share).to eql(0.5)
        end
      end

      context 'when the edge and child have demand' do
        before do
          edge.set(:demand, 200.0)
          child.set(:preset_demand, 500.0)
        end

        it 'calculates the share' do
          expect(edge.share).to eql(0.4)
        end
      end

      context 'when the edge has demand and the child does not' do
        before do
          edge.set(:demand, 200.0)
        end

        it 'does not calculate a share' do
          expect(edge.share).to be_nil
        end
      end

      context 'when the child has demand but the edge does not' do
        before do
          child.set(:preset_demand, 500.0)
        end

        it 'does not calculate a share' do
          expect(edge.share).to be_nil
        end
      end

      context 'and the edge is the only carrier supplier to the child' do
        before do
          other.disconnect_from(child, :gas)
          other.connect_to(child, :electricity)
        end

        it 'returns 1.0' do
          expect(edge.share).to eql(1.0)
        end
      end

      context 'and the edge has demand of zero' do
        before { edge.set(:demand, 0.0) }

        it 'returns 0.0' do
          expect(edge.share).to eql(0.0)
        end
      end

      context 'when the edge is one of many carrier suppliers to the child' do
        it 'does not calculate a share' do
          expect(edge.share).to be_nil
        end
      end
    end # share

  end # Edge
end # Refinery
