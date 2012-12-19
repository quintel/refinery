require 'spec_helper'

module Refinery
  describe SlotsCollection do
    let(:node) { Node.new(:node) }
    let(:coll) { SlotsCollection.new(node, :out) }

    it 'is enumerable' do
      gas  = coll.add(:gas)
      elec = coll.add(:electricity)

      expect { |b| coll.each(&b) }.to yield_successive_args(gas, elec)
    end

    describe '#add' do
      let!(:result) { coll.add(:gas, conversion: 0.5) }

      it 'adds the slot' do
        expect(coll.to_a.detect { |s| s.carrier == :gas }).to be
      end

      it 'returns the new slot' do
        expect(result).to be_a(Slot)
      end

      it 'sets the slot direction' do
        expect(result.direction).to eql(:out)
      end

      it 'sets the slot carrier' do
        expect(result.carrier).to eql(:gas)
      end

      it 'sets the given properties' do
        expect(result.properties).to eql(conversion: 0.5)
      end

      context 'when a duplicate slot is already present' do
        it 'raises SlotAlreadyExists' do
          expect { coll.add(:gas) }.to raise_error(SlotAlreadyExistsError)
        end
      end
    end # add

    describe '#include?' do
      it 'is true when such a slot exists' do
        coll.add(:gas)
        expect(coll).to include(:gas)
      end

      it 'is false when no such slot exists' do
        expect(coll).to_not include(:gas)
      end
    end # include?

    describe '#inspect' do
      it 'contains the direction' do
        expect(coll.inspect).to match(/\(out\)/)
      end

      it 'contains the node information' do
        expect(coll.inspect).to include(node.key.to_s)
      end
    end # inspect
  end # SlotsCollection
end # Refinery
