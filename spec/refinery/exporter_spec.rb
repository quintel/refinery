require 'spec_helper'

describe Refinery::Exporter do
  context 'with three nodes and sequential edges' do
    let(:graph) do
      graph  = Turbine::Graph.new

      top    = graph.add(Refinery::Node.new(:top, name: 'Head', demand: 10.0))
      middle = graph.add(Refinery::Node.new(:middle, name: 'Mid', demand: 15.0))
      bottom = graph.add(Refinery::Node.new(:bottom, name: 'Tail', demand: 20.0))

      top.connect_to(middle, :gas, child_share: 1.0)
      middle.connect_to(bottom, :electricity, child_share: 0.3)

      graph
    end

    let(:data) { Refinery::Exporter.new(graph).to_h }

    context 'the first node' do
      let(:node) { data['top'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'does not set demand' do
        expect(node).to_not have_key('demand')
      end

      it 'sets expected_demand' do
        expect(node['expected_demand']).to eql(10.0)
      end

      it 'does not set preset_demand' do
        expect(node).to_not have_key('preset_demand')
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Head')
      end

      it 'includes the outgoing gas slot' do
        expect(node['slots']).to have(1).member
        expect(node['slots'].keys.first).to eql('top-(gas)')
      end

      it 'includes the link to the second node' do
        expect(node['links']).to have(1).member

        expect(node['links'].first).
          to eql('top-(gas) -- 1.0 --> (gas)-middle')
      end
    end # the first node

    context 'the second node' do
      let(:node) { data['middle'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'does not set demand' do
        expect(node).to_not have_key('demand')
      end

      it 'sets expected_demand' do
        expect(node['expected_demand']).to eql(15.0)
      end

      it 'does not set preset_demand' do
        expect(node).to_not have_key('preset_demand')
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Mid')
      end

      it 'includes the incoming gas slot' do
        expect(node['slots'].keys).to include('(gas)-middle')
      end

      it 'includes the outgoing electricity slot' do
        expect(node['slots'].keys).to include('middle-(electricity)')
      end

      it 'includes the link to the second node' do
        expect(node['links']).to have(1).member
        expect(node['links'].first).
          to eql('middle-(electricity) -- 0.3 --> (electricity)-bottom')
      end
    end # the second node

    context 'the third node' do
      let(:node) { data['bottom'] }

      it 'is exported' do
        expect(node).to_not be_nil
      end

      it 'does not set demand' do
        expect(node).to_not have_key('demand')
      end

      it 'does not set expected_demand' do
        expect(node).to_not have_key('expected_demand')
      end

      it 'sets preset_demand' do
        expect(node['preset_demand']).to eql(20.0)
      end

      it 'includes the node attributes' do
        expect(node['name']).to eql('Tail')
      end

      it 'includes the incoming electricity slot' do
        expect(node['slots'].keys.first).to eql('(electricity)-bottom')
      end

      it 'includes no links' do
        expect(node['links']).to be_empty
      end
    end # the third node
  end # with three nodes and sequential edges
end # Refinery::Exporter
