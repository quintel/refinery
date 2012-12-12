require 'spec_helper'

describe 'Graph calculations; three siblings and two parents' do
  #                (100) [M]     [F] (50)
  #                    / / \     /
  #         __________/ /   \   /
  #        /           /     \ /
  #  (10) [B]   (75) [S]     [C]
  let!(:mother)  { graph.add Turbine::Node.new(:mother) }
  let!(:child)   { graph.add Turbine::Node.new(:child) }
  let!(:brother) { graph.add Turbine::Node.new(:brother) }
  let!(:sister)  { graph.add Turbine::Node.new(:sister) }
  let!(:father)  { graph.add Turbine::Node.new(:father) }

  let!(:mb_edge) { mother.connect_to(brother, :gas) }
  let!(:ms_edge) { mother.connect_to(sister, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas) }
  let!(:fc_edge) { father.connect_to(child, :gas) }

  before do
    brother.set(:preset_demand, 10.0)
    sister.set(:preset_demand, 75.0)
    mother.set(:expected_demand, 100.0)
    father.set(:expected_demand, 50.0)
    calculate!
  end

  it 'sets child demand' do
    pending do
      expect(demand(child)).to eql(65.0)
    end
  end

  it 'sets edge shares' do
    pending do
      expect(mb_edge.get(:share)).to eql(0.10)
      expect(ms_edge.get(:share)).to eql(0.75)
      expect(mc_edge.get(:share)).to eql(0.15)
      expect(fc_edge.get(:share)).to eql(1.00)
    end
  end
end # Graph calculations; three siblings and two parents
