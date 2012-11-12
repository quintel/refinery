require 'spec_helper'

module Refinery::Catalyst
  describe BackportDemand do
    context 'when a node has a single filled-in descendant' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant, expected_demand: 40.0))
          graph.add(Turbine::Node.new(:ancestor))

          graph.node(:ancestor).connect_to(
            graph.node(:descendant), :gas, share: 1.0)
        end
      end

      before { Refinery::Catalyst::BackportDemand.call(graph) }

      it 'sets expected demand on the ancestor' do
        expect(graph.node(:ancestor).get(:expected_demand)).to eql(40.0)
      end

      it 'does not affect the descendant' do
        expect(graph.node(:descendant).get(:expected_demand)).to eql(40.0)
      end
    end # when a node has a single filled-in descendant

    context 'when a node has two filled-in descendants' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:descendant_one, expected_demand: 40.0))
          graph.add(Turbine::Node.new(:descendant_two, expected_demand: 80.0))
          graph.add(Turbine::Node.new(:ancestor))

          graph.node(:ancestor).connect_to(
            graph.node(:descendant_one), :gas, share: 0.7)

          graph.node(:ancestor).connect_to(
            graph.node(:descendant_two), :gas, share: 0.3)
        end
      end

      before { Refinery::Catalyst::BackportDemand.call(graph) }

      it 'sets expected demand based on the descendants' do
        expect(graph.node(:ancestor).get(:expected_demand)).to eql(120.0)
      end

      it 'does not affect the descendants' do
        expect(graph.node(:descendant_one).get(:expected_demand)).to eql(40.0)
        expect(graph.node(:descendant_two).get(:expected_demand)).to eql(80.0)
      end
    end # when a node has two filled-in descendants

    context 'when the descendant has multiple sources' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:ancestor_one))
          graph.add(Turbine::Node.new(:ancestor_two))
          graph.add(Turbine::Node.new(:descendant, expected_demand: 100.0))

          graph.node(:ancestor_one).connect_to(
            graph.node(:descendant), :gas, share: 0.3)

          graph.node(:ancestor_two).connect_to(
            graph.node(:descendant), :gas, share: 0.2)
        end
      end

      before { Refinery::Catalyst::BackportDemand.call(graph) }

      it 'assigns demand proportionally to the first ancestor' do
        expect(graph.node(:ancestor_one).get(:expected_demand)).to eql(60.0)
      end

      it 'assigns demand proportionally to the second ancestor' do
        expect(graph.node(:ancestor_two).get(:expected_demand)).to eql(40.0)
      end

      it 'does not affect the descendant' do
        expect(graph.node(:descendant).get(:expected_demand)).to eql(100.0)
      end
    end # when the descendant has multiple sources

    context 'when a node has a blank descendant', focus: true do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:child))
          graph.add(Turbine::Node.new(:parent))
        end
      end

      before { Refinery::Catalyst::BackportDemand.call(graph) }

      it 'sets demand to be 0.0' do
        expect(graph.node(:child).get(:expected_demand)).to be_zero
      end
    end # when a node has a blank descendant

    context 'when there is a chain of blank descendants' do
      let(:graph) do
        Turbine::Graph.new.tap do |graph|
          graph.add(Turbine::Node.new(:grandparent))
          graph.add(Turbine::Node.new(:parent))
          graph.add(Turbine::Node.new(:child, expected_demand: 50.0))

          graph.node(:grandparent).connect_to(
            graph.node(:parent), :gas, share: 1.0)

          graph.node(:parent).connect_to(
            graph.node(:child), :gas, share: 1.0)
        end
      end

      before { Refinery::Catalyst::BackportDemand.call(graph) }

      it 'sets expected demand on the parent' do
        expect(graph.node(:parent).get(:expected_demand)).to eql(50.0)
      end

      it 'sets expected demand on the grandparent' do
        expect(graph.node(:grandparent).get(:expected_demand)).to eql(50.0)
      end

      it 'does not affect the child' do
        expect(graph.node(:child).get(:expected_demand)).to eql(50.0)
      end
    end # when there is a change on blank descendants
  end # BackportDemand
end # Refinery::Cayalyst
