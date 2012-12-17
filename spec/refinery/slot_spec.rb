require 'spec_helper'

module Refinery
  describe Slot do
    let(:graph)   { Turbine::Graph.new }
    let(:parent)  { graph.add Node.new(:parent, expected_demand: 50.0) }
    let(:spouse)  { graph.add Node.new(:spouse, expected_demand: 10.0) }
    let(:child)   { graph.add Node.new(:child)   }
    let(:sibling) { graph.add Node.new(:sibling) }

    before do
      [ parent, spouse ].each do |person|
        person.connect_to(child, :gas, share: 0.5)
        person.connect_to(sibling, :gas, share: 0.5)
      end

      Catalyst::Calculators.new(graph).run!
    end

    # ------------------------------------------------------------------------

    context 'on a node with outgoing edges' do
      let(:slot) { Slot.new(parent, :out, :gas) }

      it 'is an :out slot' do
        expect(slot.direction).to eql(:out)
      end

      it 'sets the carrier' do
        expect(slot.carrier).to eql(:gas)
      end

      it 'sums the demand of each link' do
        expect(slot.demand).to eql(50.0)
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
        expect(slot.demand).to eql(30.0)
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
