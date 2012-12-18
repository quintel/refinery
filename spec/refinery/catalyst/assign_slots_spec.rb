require 'spec_helper'

module Refinery::Catalyst
  describe AssignSlots do
    let!(:graph) { Turbine::Graph.new }

    let!(:mother)    { graph.add Refinery::Node.new(:mother) }
    let!(:father)    { graph.add Refinery::Node.new(:father) }
    let!(:child_one) { graph.add Refinery::Node.new(:child_one) }
    let!(:child_two) { graph.add Refinery::Node.new(:child_two) }

    before do
      [ [mother, father], [father, mother] ].each do |(person, other)|
        person.connect_to(other, :spouse)

        person.connect_to(child_one, :child)
        person.connect_to(child_two, :child)

        child_one.connect_to(person, :parent)
        child_two.connect_to(person, :parent)
      end

      child_one.connect_to(child_two, :sibling)
      child_two.connect_to(child_one, :sibling)
    end

    # ------------------------------------------------------------------------

    context 'when a node has incoming edges' do
      context 'and no slots are predefined' do
        before { AssignSlots.call(graph) }

        it 'stores the incoming slots' do
          expect(child_one.get(:slots)).to have_key(:in)
          expect(child_one.get(:slots)[:in]).to have(2).slots
        end

        it 'assigns the :parent slot' do
          expect(child_one.get(:slots)[:in][:child]).to be
        end

        it 'assigns the :sibling slot' do
          expect(child_one.get(:slots)[:in][:sibling]).to be
        end
      end # and no slots are predefined

      context 'and one of the slots is already present' do
        let!(:exists) do
          Refinery::Slot.new(child_one, :in, :sibling, share: 0.5)
        end

        before do
          child_one.set(:slots, in: { sibling: exists })
          AssignSlots.call(graph)
        end

        it 'stores the incoming slots' do
          expect(child_one.get(:slots)).to have_key(:in)
          expect(child_one.get(:slots)[:in]).to have(2).slots
        end

        it 'assigns the non-present slot' do
          expect(child_one.get(:slots)[:in][:child]).to be
        end

        it 'does not reassign the existing slot' do
          slot = child_one.get(:slots)[:in][:sibling]

          expect(slot).to eql(exists)
          expect(slot.get(:share)).to eql(0.5)
        end
      end # and one of the slots is already present
    end # when a node has incoming edges

    context 'when a node has outgoing edges' do
      context 'and no slots are predefined' do
        before { AssignSlots.call(graph) }

        it 'stores the outgoing slots' do
          expect(child_one.get(:slots)).to have_key(:out)
          expect(child_one.get(:slots)[:out]).to have(2).slots
        end

        it 'assigns the :child slot' do
          expect(mother.get(:slots)[:out][:child]).to be
        end

        it 'assigns the :spouse slot' do
          expect(mother.get(:slots)[:out][:spouse]).to be
        end
      end # and no slots are predefined

      context 'and one of the slots is already present' do
        let!(:exists) do
          Refinery::Slot.new(mother, :out, :child, share: 0.5)
        end

        before do
          mother.set(:slots, out: { child: exists })
          AssignSlots.call(graph)
        end

        it 'stores the outgoing slots' do
          expect(mother.get(:slots)).to have_key(:out)
          expect(mother.get(:slots)[:out]).to have(2).slots
        end

        it 'assigns the non-present slot' do
          expect(mother.get(:slots)[:out][:spouse]).to be
        end

        it 'does not reassign the existing slot' do
          slot = mother.get(:slots)[:out][:child]

          expect(slot).to eql(exists)
          expect(slot.get(:share)).to eql(0.5)
        end
      end # and one of the slots is already present
    end # when a node has outgoing edges

  end # AssignSlots
end # Refinery::Catalyst
