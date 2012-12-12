require 'spec_helper'

describe 'Graph calculations; with a sibling which is also a parent' do
  #    (100) [M] [F] (50)
  #          / \ /
  #   (0.2) /__[S]       Someone call Jerry Springer...
  #        //
  #       [C]
  let!(:mother)  { graph.add Turbine::Node.new(:mother) }
  let!(:child)   { graph.add Turbine::Node.new(:child) }
  let!(:sibling) { graph.add Turbine::Node.new(:sibling) }
  let!(:father)  { graph.add Turbine::Node.new(:father) }

  let!(:ms_edge) { mother.connect_to(sibling, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.2) }
  let!(:sc_edge) { sibling.connect_to(child, :gas) }
  let!(:fs_edge) { father.connect_to(sibling, :gas) }

  before do
    mother.set(:expected_demand, 100.0)
    father.set(:expected_demand, 50.0)
    calculate!
  end

  it 'sets child demand' do
    pending do
      expect(demand(child)).to eql(1.0)
    end
  end

  it 'sets edge shares' do
    expect(ms_edge.get(:share)).to eql(0.8)
    expect(fs_edge.get(:share)).to eql(1.0)
    expect(sc_edge.get(:share)).to eql(1.0)
  end
end # Graph calculations; with a sibling which is also a parent
