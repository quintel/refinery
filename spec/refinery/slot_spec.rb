require 'spec_helper'

module Refinery
  describe Slot do
    let(:graph)   { Turbine::Graph.new }
    let(:parent)  { graph.add Node.new(:parent,  demand:  60.0) }
    let(:spouse)  { graph.add Node.new(:spouse,  demand:  60.0) }
    let(:child)   { graph.add Node.new(:child,   demand:  40.0) }
    let(:sibling) { graph.add Node.new(:sibling, demand:  80.0) }

    before do
      [ parent, spouse ].each do |person|
        person.connect_to(child, :gas, demand: child.demand * 0.5)
        person.connect_to(sibling, :gas, demand: sibling.demand * 0.5)
      end
    end

    # ------------------------------------------------------------------------

    context 'on a node with outgoing edges' do
      let(:slot) { Slot.new(parent, :out, :gas) }

      it 'is an :out slot' do
        expect(slot.direction).to eq(:out)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eq(:gas)
      end

      it 'sums the demand of each link' do
        expect(slot.demand).to eq(60.0)
      end
    end # on a node with outgoing edges

    context 'on a node with incoming edges' do
      let(:slot) { Slot.new(child, :in, :gas) }

      it 'is an :in slot' do
        expect(slot.direction).to eq(:in)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eq(:gas)
      end

      it 'sums the demand of each link' do
        expect(slot.demand).to eq(40.0)
      end
    end # on a node with incoming edges

    context 'when there are no carrier-matching edges' do
      let(:slot) { Slot.new(parent, :out, :electricity) }

      it 'is an :out slot' do
        expect(slot.direction).to eq(:out)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eq(:electricity)
      end

      it 'has no demand' do
        expect(slot.demand).to be_zero
      end
    end # when there are no carrier-matching edges

    context 'when there are no direction-matching edges' do
      let(:slot) { Slot.new(parent, :in, :gas) }

      it 'is an :in slot' do
        expect(slot.direction).to eq(:in)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eq(:gas)
      end

      it 'has no demand' do
        expect(slot.demand).to be_zero
      end
    end # when there are no direction-matching edges

    context 'when an edge does not have demand' do
      let(:slot) { Slot.new(parent, :out, :gas) }
      before { expect(slot.edges.first).to receive(:demand).and_return(nil) }

      it 'has no demand' do
        expect(slot.demand).to be_nil
      end
    end # when an edge does not have demand

    describe 'share' do
      let(:slot) { parent.slots.out(:gas) }

      context 'as the only carrier on the node' do
        it 'is 1.0 when no explicit value is set' do
          expect(slot.share).to eq(1)
        end

        it 'uses the explicit value when provided' do
          slot.set(:share, 0.5)
          expect(slot.share).to eq(0.5)
        end
      end # as the only carrier on the node

      context 'as one of many carriers on the node' do
        let!(:elec_edge) { parent.connect_to(child, :electricity) }

        before do
          slot.edges.each { |e| e.set(:demand, e.get(:demand) - 10) }
        end

        context 'and demand of one slot is missing' do
          context 'and demand of the node is unknown' do
            before { parent.set(:demand, nil) }

            it 'returns nil' do
              expect(slot.share).to be_nil
            end
          end # and demand of the node is unknown

          context 'but the node has a demand set' do
            it 'calculates the slot share' do
              expect(slot.share).to eq(2.0 / 3.0)
            end
          end # but the node has a demand set
        end # and demand is one slot is missing

        context 'and demands are known for all slots' do
          before do
            parent.set(:demand, nil)
            elec_edge.set(:demand, 20)
          end

          it 'calculates the slot share' do
            expect(slot.share).to eq(2.0 / 3.0)
          end
        end # and demands are known for all slots
      end # as one of many carriers on the node
    end # share
  end # Slot
end # Refinery
