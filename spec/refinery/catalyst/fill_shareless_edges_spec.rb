require 'spec_helper'

describe Refinery::Catalyst::FillSharelessEdges do
  let(:parent) { Turbine::Node.new(:parent) }
  let(:child)  { Turbine::Node.new(:child) }

  let(:graph) do
    Turbine::Graph.new.tap do |graph|
      graph.add(parent)
      graph.add(child)
    end
  end

  context 'with a node containing a single share-less edge' do
    let!(:edge) { parent.connect_to(child, :gas) }

    it 'sets a share value of 1.0' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to change { edge.get(:share) }.from(nil).to(1.0)
    end
  end # with a node containing a single share-less edge

  context 'with a node containing a single share edge' do
    let!(:edge) { parent.connect_to(child, :gas, share: 0.5) }

    it 'does not change the edge share value' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to_not change { edge.get(:share) }
    end
  end # with a node contaiing a single share edge

  context 'with a node containing two share-less edges' do
    let!(:edge_one) { parent.connect_to(child, :gas,  share: 0.5) }
    let!(:edge_two) { parent.connect_to(child, :elec, share: 0.5) }

    it 'does not change the first edge share value' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to_not change { edge_one.get(:share) }
    end

    it 'does not change the second edge share value' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to_not change { edge_two.get(:share) }
    end
  end # with a node containing two share-less edges

  context 'with a node containing one share edge, and one share-less edge' do
    let!(:edge_one) { parent.connect_to(child, :gas, share: 0.5) }
    let!(:edge_two) { parent.connect_to(child, :elec) }

    it 'does not change the first edge share value' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to_not change { edge_one.get(:share) }
    end

    it 'does not change the second edge share value' do
      expect {
        Refinery::Catalyst::FillSharelessEdges.call(graph)
      }.to_not change { edge_two.get(:share) }
    end
  end # with a node containing one share edge, and one share-less edge
end # FillSharelessEdges
