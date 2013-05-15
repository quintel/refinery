require 'spec_helper'

module Refinery::Catalyst
  describe FromTurbine do
    let(:turbine) do
      turbine = Turbine::Graph.new

      parent = turbine.add(Turbine::Node.new(:parent, demand: 50.0))
      child  = turbine.add(Turbine::Node.new(:child))

      parent.connect_to(child, :gas, parent_share: 0.3)

      turbine
    end

    let(:refinery) { FromTurbine.call(turbine) }

    describe 'the parent node' do
      it 'has its key set' do
        expect(refinery.node(:parent).key).to be
      end

      it 'is a Refinery node' do
        expect(refinery.node(:parent)).to be_a(Refinery::Node)
      end

      it 'has its demand set' do
        expect(refinery.node(:parent).get(:demand)).to eq(50)
      end
    end

    describe 'the child node' do
      it 'has its key set' do
        expect(refinery.node(:child).key).to be
      end

      it 'is a Refinery node' do
        expect(refinery.node(:child)).to be_a(Refinery::Node)
      end

      it 'has no demand set, since the original has none' do
        expect(refinery.node(:child).get(:demand)).to be_nil
      end
    end

    describe 'the parent->child edge' do
      let(:edge) { refinery.node(:parent).out_edges.first }

      it 'is added to the Refinery graph' do
        expect(edge).to be
      end

      it 'is a Refinery edge' do
        expect(edge).to be_a(Refinery::Edge)
      end

      it 'has a label set, matching the original' do
        expect(edge.label).to eql(:gas)
      end

      it 'has the share set' do
        expect(edge.get(:parent_share)).to eq(0.3)
      end
    end

  end # describe FromTurbine
end # Refinery::Catalyst
