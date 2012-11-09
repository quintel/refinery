require 'spec_helper'

module Refinery::Catalyst
  describe CalculateDemand do
    let(:grandparent) { Turbine::Node.new(:grandparent, final_demand: 50.0) }
    let(:parent)      { Turbine::Node.new(:parent) }
    let(:child_one)   { Turbine::Node.new(:child_one) }
    let(:child_two)   { Turbine::Node.new(:child_two) }

    let(:graph) do
      Turbine::Graph.new.tap do |graph|
        graph.add(grandparent)
        graph.add(parent)
        graph.add(child_one)
        graph.add(child_two)

        grandparent.connect_to(parent, :gas, share: 1.0)
        parent.connect_to(child_one, :gas, share: 0.6)
        parent.connect_to(child_two, :gas, share: 0.4)
      end
    end

    before { CalculateDemand.new(graph.node(:grandparent)).calculate! }

    # ------------------------------------------------------------------------

    it 'should propagate demand to child nodes with :expected_demand' do
      expect(parent.get(:expected_demand)).to eql(50.0)
      expect(parent.get(:preset_demand)).to be_nil
    end

    it 'should propagate demand to leaf nodes with :preset_demand' do
      expect(child_one.get(:preset_demand)).to eql(30.0)
      expect(child_two.get(:preset_demand)).to eql(20.0)

      expect(child_one.get(:expected_demand)).to be_nil
      expect(child_two.get(:expected_demand)).to be_nil
    end
  end # CalculateDemand
end # Refinery::Catalyst
