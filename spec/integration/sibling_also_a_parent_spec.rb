require 'spec_helper'

describe 'Graph calculations; with a sibling which is also a parent' do
  #     (100) [M] [F] (50)
  #           / \ /
  #   (0.13) /__[S]       Someone call Jerry Springer...
  #         //
  #  (150) [C]
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }
  let!(:father)  { graph.add Refinery::Node.new(:father) }

  let!(:ms_edge) { mother.connect_to(sibling, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas, share: 20.0 / 150) }
  let!(:sc_edge) { sibling.connect_to(child, :gas) }
  let!(:fs_edge) { father.connect_to(sibling, :gas) }

  before do
    mother.set(:expected_demand, 100.0)
    father.set(:expected_demand, 50.0)
    child.set(:preset_demand, 150.0)
    calculate!
  end

  it 'sets child demand' do
    expect(child.demand).to eql(150.0)
  end

  it 'sets sibling demand' do
    expect(sibling.demand).to eql(130.0)
  end

  it 'sets M->S share' do
    expect(ms_edge.get(:share)).to eql(80.0 / 130)
  end

  it 'sets F->S share' do
    expect(fs_edge.get(:share)).to be_within(1e-9).of(50.0 / 130)
  end

  it 'sets S->C share' do
    expect(sc_edge.get(:share)).to eql(130.0 / 150)
  end
end # Graph calculations; with a sibling which is also a parent
