require 'spec_helper'

module Refinery
  describe Slot do
    let(:graph)   { Turbine::Graph.new }
    let(:parent)  { graph.add Node.new(:parent,  expected_demand: 100.0) }
    let(:spouse)  { graph.add Node.new(:spouse,  expected_demand: 20.0) }
    let(:child)   { graph.add Node.new(:child,   preset_demand:   40.0) }
    let(:sibling) { graph.add Node.new(:sibling, preset_demand:   80.0) }

    before do
      [ parent, spouse ].each do |person|
        person.connect_to(child, :gas, demand: child.demand * 0.5)
        person.connect_to(sibling, :gas, demand: sibling.demand * 0.5)
      end
    end

    # ------------------------------------------------------------------------

    context 'when initialized' do
      it 'defaults "share" to 1.0' do
        slot = Slot.new(parent, :out, :gas)
        expect(slot.get(:share)).to eql(1.0)
      end

      it 'accepts a custom "share" when provided' do
        slot = Slot.new(parent, :out, :gas, share: 0.3)
        expect(slot.get(:share)).to eql(0.3)
      end
    end

    context 'on a node with outgoing edges' do
      let(:slot) { Slot.new(parent, :out, :gas) }

      it 'is an :out slot' do
        expect(slot.direction).to eql(:out)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eql(:gas)
      end

      it 'sums the demand of each link' do
        expect(slot.demand).to eql(60.0)
      end
    end # on a node with outgoing edges

    context 'on a node with incoming edges' do
      let(:slot) { Slot.new(child, :in, :gas) }

      it 'is an :in slot' do
        expect(slot.direction).to eql(:in)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eql(:gas)
      end

      it 'sums the demand of each link' do
        expect(slot.demand).to eql(40.0)
      end
    end # on a node with incoming edges

    context 'when there are no carrier-matching edges' do
      let(:slot) { Slot.new(parent, :out, :electricity) }

      it 'is an :out slot' do
        expect(slot.direction).to eql(:out)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eql(:electricity)
      end

      it 'has no demand' do
        expect(slot.demand).to be_zero
      end
    end # when there are no carrier-matching edges

    context 'when there are no direction-matching edges' do
      let(:slot) { Slot.new(parent, :in, :gas) }

      it 'is an :in slot' do
        expect(slot.direction).to eql(:in)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eql(:gas)
      end

      it 'has no demand' do
        expect(slot.demand).to be_zero
      end
    end # when there are no direction-matching edges

    context 'when an edge does not have demand' do
      let(:slot) { Slot.new(parent, :out, :gas) }
      before { slot.edges.first.should_receive(:demand).and_return(nil) }

      it 'has no demand' do
        expect(slot.demand).to be_nil
      end
    end # when an edge does not have demand
  end # Slot
end # Refinery
