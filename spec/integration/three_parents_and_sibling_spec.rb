require 'spec_helper'

describe 'Graph calculations; three parents and a sibling' do
  #     (100) [M]     [F] (15)   [R]
  #           / \     /          /
  #          /   \   / _________/
  #         /     \ / /
  #  (75) [S]     [C] (125)
  let!(:mother)   { graph.add Turbine::Node.new(:mother) }
  let!(:child)    { graph.add Turbine::Node.new(:child) }
  let!(:sibling)  { graph.add Turbine::Node.new(:sibling) }
  let!(:father)   { graph.add Turbine::Node.new(:father) }
  let!(:relative) { graph.add Turbine::Node.new(:relative) }

  let!(:ms_edge)  { mother.connect_to(sibling, :gas) }
  let!(:mc_edge)  { mother.connect_to(child, :gas) }
  let!(:fc_edge)  { father.connect_to(child, :gas) }
  let!(:rc_edge)  { relative.connect_to(child, :gas) }

  before do
    sibling.set(:preset_demand, 75.0)
    mother.set(:expected_demand, 100.0)
    child.set(:preset_demand, 125.0)
    father.set(:expected_demand, 15.0)
    calculate!
  end

  context 'with no edge shares' do
    it 'sets edge shares' do
      pending do
        expect(ms_edge.get(:share)).to eql(0.75)
        expect(mc_edge.get(:share)).to eql(0.25)
        expect(fc_edge.get(:share)).to eql(1.0)
        expect(rc_edge.get(:share)).to eql(1.0)
      end
    end

    it 'sets demand for the third parent' do
      pending do
        expect(demand(relative)).to eql(85.0)
      end
    end
  end

  context 'with a share on the third parent' do
    before do
      rc_edge.set(:share, 0.2)
      calculate!
    end

    it 'sets demand for the third parent' do
      pending do
        expect(demand(relative)).to eql(85.0 / 0.2)
      end
    end
  end
end # Graph calculations; three parents and a sibling