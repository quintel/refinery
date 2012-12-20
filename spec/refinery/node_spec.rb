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
  end # Node
end # Refinery
