require 'spec_helper'

module Refinery::Catalyst
  describe SetSlotShares do
    let(:graph)   { Turbine::Graph.new }
    let!(:mother) { graph.add Refinery::Node.new(:mother) }
    let!(:father) { graph.add Refinery::Node.new(:father) }
    let!(:child)  { graph.add Refinery::Node.new(:child) }

    before do
      mother.connect_to(child, :child)
      father.connect_to(child, :child)
    end

    def share(node, direction, carrier)
      node.get(:slots)[direction][carrier].get(:share)
    end

    # ------------------------------------------------------------------------

    describe 'when all slots are orphans' do
      before do
        AssignSlots.call(graph)
        SetSlotShares.call(graph)
      end

      it 'assigns shares to output slots' do
        expect(share(mother, :out, :child)).to eql(1.0)
      end

      it 'assigns shares to input slots' do
        expect(share(child, :in, :child)).to eql(1.0)
      end
    end # when all slots are orphans

    describe 'when a slot is not an orphan' do
      before do
        mother.connect_to(father, :spouse)
      end

      context 'and both have a "share"' do
        before do
          AssignSlots.call(graph)

          mother.get(:slots)[:out][:child].set(:share, 0.7)
          mother.get(:slots)[:out][:spouse].set(:share, 0.3)

          SetSlotShares.call(graph)
        end

        it 'does not change the share value of the first' do
          expect(share(mother, :out, :child)).to eql(0.7)
        end

        it 'does not change the share value of the second' do
          expect(share(mother, :out, :spouse)).to eql(0.3)
        end
      end

      context 'and one is without a "share"' do
        before do
          AssignSlots.call(graph)
          mother.get(:slots)[:out][:spouse].set(:share, 0.5)
        end

        it 'raises an error' do
          expect { SetSlotShares.call(graph) }.
            to raise_error(Refinery::TooManySlotsError)
        end
      end
    end # when a slot is not an orphan

    describe 'and a slot has a predefined share' do
      before do
        AssignSlots.call(graph)
        mother.get(:slots)[:out][:child].set(:share, 0.5)
        SetSlotShares.call(graph)
      end

      it 'does not change the share value' do
        expect(share(mother, :out, :child)).to eql(0.5)
      end
    end # and a slot has a predefined share

  end # SetSlotShares
end # Refinery::Catalyst
