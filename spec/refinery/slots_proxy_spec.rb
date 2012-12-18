require 'spec_helper'

module Refinery
  describe SlotsProxy do
    let(:node)  { Node.new(:node) }
    let(:proxy) { SlotsProxy.new(node) }

    let(:in_slots) {{
      one: Slot.new(node, :in, :one),
      two: Slot.new(node, :in, :two)
    }}

    let(:out_slots) {{
      three: Slot.new(node, :out, :three),
      four:  Slot.new(node, :out, :four)
    }}

    before do
      node.set(:slots, in: in_slots, out: out_slots)
    end

    # ------------------------------------------------------------------------

    describe '#in' do
      context 'when unqualified' do
        it 'returns all the incoming slots' do
          expect(proxy.in).to eql(in_slots.values)
        end
      end

      context 'with a carrier' do
        it 'returns a Slot when one matches' do
          expect(proxy.in(:one)).to eql(in_slots[:one])
        end

        it 'returns nil when no slot matches' do
          expect(proxy.in(:nope)).to be_nil
        end
      end
    end # in

    describe '#out' do
      context 'when unqualified' do
        it 'returns all the outgoing slots' do
          expect(proxy.out).to eql(out_slots.values)
        end
      end

      context 'with a carrier' do
        it 'returns a Slot when one matches' do
          expect(proxy.out(:three)).to eql(out_slots[:three])
        end

        it 'returns nil when no slot matches' do
          expect(proxy.out(:nope)).to be_nil
        end
      end
    end # out
  end # SlotsProxy
end # Refinery
