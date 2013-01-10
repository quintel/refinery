require 'spec_helper'

module Refinery
  describe Node do
    context 'Connecting two nodes' do
      let(:node) { Node.new(:node) }

      it 'connects using a Refinery::Edge' do
        expect(node.connect_to(node, :gas)).to be_a(Refinery::Edge)
      end

      it 'creates the incoming slot' do
        expect { node.connect_to(node, :gas) }.
          to change { node.slots.in.length }.from(0).to(1)

        expect(node.slots.in(:gas)).to be
      end

      it 'creates the outgoing slot' do
        expect { node.connect_to(node, :gas) }.
          to change { node.slots.out.length }.from(0).to(1)

        expect(node.slots.out(:gas)).to be
      end

      context 'when appropriate slots already exist' do
        before { node.connect_to(node, :gas) }
        let(:other) { Node.new(:other) }

        it 'does not raise an error' do
          expect { node.connect_to(other, :gas) }.to_not raise_error
        end

        it 'does not create an additional slot' do
          node.connect_to(other, :gas)

          expect(node.slots.out.length).to eql(1)
          expect(other.slots.in.length).to eql(1)
        end
      end
    end # Connecting two nodes

    context 'demand_for' do
      let(:node) { Node.new(:node, preset_demand: 50.0) }
      before     { node.slots.in.add(:gas) }

      it "is derrived from the node's demand" do
        expect(node.demand_for(:gas)).to eql(50.0)
      end

      it 'accounts for the slot share' do
        node.slots.in(:gas).set(:share, 0.4)
        expect(node.demand_for(:gas)).to eql(20.0)
      end

      it 'is nil if the node has no demand defined' do
        node.set(:preset_demand, nil)
        expect(node.demand_for(:gas)).to be_nil
      end

      it 'raises an error if no such carrier is present on the node' do
        expect { node.demand_for(:electricity) }.
          to raise_error(Refinery::NoSuchCarrierError)
      end
    end # demand_for

    context 'output_of' do
      let(:node) { Node.new(:node, preset_demand: 50.0) }
      before     { node.slots.out.add(:gas) }

      it "is derrived from the node's demand" do
        expect(node.output_of(:gas)).to eql(50.0)
      end

      it 'accounts for the slot share' do
        node.slots.out(:gas).set(:share, 0.4)
        expect(node.output_of(:gas)).to eql(20.0)
      end

      it 'is nil if the node has no demand defined' do
        node.set(:preset_demand, nil)
        expect(node.output_of(:gas)).to be_nil
      end

      it 'raises an error if no such carrier is present on the node' do
        expect { node.output_of(:electricity) }.
          to raise_error(Refinery::NoSuchCarrierError)
      end
    end # output_of
  end # Node
end # Refinery
