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
      it 'does not set :demand' do
        expect(no_demand.get(:demand)).to be_nil
      end
    end

    context 'nodes with :final_demand' do
      it 'sets :demand to equal :final_demand' do
        expect(non_leaf.get(:demand)).to eql(50.0)
      end
    end

  end # ConvertFinalDemand
end # Refinery::Catalyst
