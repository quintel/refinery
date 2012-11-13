require 'spec_helper'

module Refinery::Catalyst
  describe ReverseFillEdges do
    before { Refinery::Catalyst::ReverseFillEdges.call(graph) }

    # Two nodes, connected by a single link.
    context 'with a single descendant node with demand' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant, expected_demand: 50.0))
          graph.add(Turbine::Node.new(:ancestor))
          graph.node(:ancestor).connect_to(graph.node(:descendant), :gas)
        end
      end

      let(:edge) do
        graph.node(:ancestor).out_edges.first
      end

      it 'sets the edge share to be 1.0' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end # with a single descendant node with demand

    # A parent node with two child nodes. Both of the edges between the parent
    # and children are lacking a share value.
    context 'with multiple descendant nodes with demand' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant_one, expected_demand: 40.0))
          graph.add(Turbine::Node.new(:descendant_two, expected_demand: 10.0))
          graph.add(Turbine::Node.new(:ancestor))

          graph.node(:ancestor).connect_to(graph.node(:descendant_one), :gas)
          graph.node(:ancestor).connect_to(graph.node(:descendant_two), :gas)
        end
      end

      let(:edge_one) do
        graph.node(:descendant_one).in_edges.first
      end

      let(:edge_two) do
        graph.node(:descendant_two).in_edges.first
      end

      it 'sets a share value for the first edge' do
        expect(edge_one.get(:share)).to eql(0.8)
      end

      it 'sets a share value for the second edge' do
        expect(edge_two.get(:share)).to eql(0.2)
      end
    end # with multiple descendant nodes with demand

    # A parent node with an edge to a child node. The child node has a second
    # parent which also supplies energy.
    context 'when the descendant has multiple parents' do
      it 'accounts for the energy supplied by the other parent'
    end # when the descendant has multiple parents

    # A parent node with two child nodes. One of the child nodes also receives
    # energy from a third unrelated parent.
    context 'with two descendants, and a third unrelated parent' do
      it 'sets a share value for the first edge'
      it 'accounts for the energy supplied by the third parent'
    end # with two descendants, and a third unrelated parent

    # A parent and child node. The child node does not have a demand value.
    context 'when the descendant node does not define demand' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant))
          graph.add(Turbine::Node.new(:ancestor))

          graph.node(:ancestor).connect_to(graph.node(:descendant), :gas)
        end
      end

      let(:edge) do
        graph.node(:ancestor).out_edges.first
      end

      it 'does not set a share value' do
        expect(edge.get(:share)).to be_nil
      end
    end # when the descendant node does not define demand

    # A parent node with two children. One of the child nodes does not have a
    # demand value.
    context 'when a descendant sibling node does not define demand' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant_one))
          graph.add(Turbine::Node.new(:descendant_two, expected_demand: 50.0))
          graph.add(Turbine::Node.new(:ancestor))

          graph.node(:ancestor).connect_to(graph.node(:descendant_one), :gas)
          graph.node(:ancestor).connect_to(graph.node(:descendant_two), :gas)
        end
      end

      let(:edge_one) do
        graph.node(:descendant_one).in_edges.first
      end

      let(:edge_two) do
        graph.node(:descendant_two).in_edges.first
      end

      it 'does not set a share value for the first edge' do
        expect(edge_one.get(:share)).to be_nil
      end

      it 'does not set a share value for the second edge' do
        expect(edge_two.get(:share)).to be_nil
      end
    end # when a descendant sibling node does not define demand
  end # ReverseFillEdges
end # Refinery::Catalyst
