require 'spec_helper'

describe Refinery::Exporter do
  context 'with three nodes and sequential edges' do
    let(:graph) do
      graph  = Turbine::Graph.new

      top    = graph.add(Turbine::Node.new(:top, name: 'Head'))
      middle = graph.add(Turbine::Node.new(:middle, name: 'Mid'))
      bottom = graph.add(Turbine::Node.new(:bottom, name: 'Tail'))

      top.connect_to(middle, :gas)
      middle.connect_to(bottom, :electricity)

      graph
    end

    let(:data) { Refinery::Exporter.new(graph).to_h }

    context 'the first node' do
      let(:node) { data['top'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Head')
      end

      it 'includes the link to the second node' do
        expect(node['links']).to have(1).member
        expect(node['links'].first).to eql('top-(gas) -- ? --> (gas)-middle')
      end
    end # the first node

    context 'the second node' do
      let(:node) { data['middle'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Mid')
      end

      it 'includes the link to the second node' do
        expect(node['links']).to have(1).member
        expect(node['links'].first).
          to eql('middle-(electricity) -- ? --> (electricity)-bottom')
      end
    end # the second node

    context 'the third node' do
      let(:node) { data['bottom'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Tail')
      end

      it 'includes no links' do
        expect(node['links']).to be_empty
      end
    end # the third node
  end # with three nodes and sequential edges
end # Refinery::Exporter
