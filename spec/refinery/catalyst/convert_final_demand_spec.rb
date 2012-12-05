require 'spec_helper'

module Refinery::Catalyst
  describe ConvertFinalDemand do
    let!(:graph)     { Turbine::Graph.new }

    let!(:no_demand) { graph.add Turbine::Node.new(:a) }
    let!(:non_leaf)  { graph.add Turbine::Node.new(:b, final_demand: 50.0) }
    let!(:leaf)      { graph.add Turbine::Node.new(:c, final_demand: 25.0) }

    before do
      non_leaf.connect_to(no_demand, :gas)
      ConvertFinalDemand.call(graph)
    end

    # ------------------------------------------------------------------------

    context 'nodes with no :final_demand' do
      it 'does not set :expected_demand' do
        expect(no_demand.get(:expected_demand)).to be_nil
      end

      it 'does not set :preset_demand' do
        expect(no_demand.get(:preset_demand)).to be_nil
      end
    end

    context 'non-leaf nodes with :final_demand' do
      it 'sets :expected_demand to equal :final_demand' do
        expect(non_leaf.get(:expected_demand)).to eql(50.0)
      end

      it 'does not set :preset_demand' do
        expect(non_leaf.get(:preset_demand)).to be_nil
      end
    end

    context 'leaf nodes with :final_demand' do
      it 'does not set :expected_demand' do
        expect(leaf.get(:expected_demand)).to be_nil
      end

      it 'sets :preset_demand to equal :final_demand' do
        expect(leaf.get(:preset_demand)).to eql(25.0)
      end
    end

  end # ConvertFinalDemand
end # Refinery::Catalyst
