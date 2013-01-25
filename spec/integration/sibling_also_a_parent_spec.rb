require 'spec_helper'

describe 'Graph calculations; with a sibling which is also a parent' do
  #     (100) [M] [F] (50)
  #           / \ /
  #     (20) /__[S]       Someone call Jerry Springer...
  #         //
  #  (150) [C]
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }
  let!(:father)  { graph.add Refinery::Node.new(:father) }

  let!(:ms_edge) { mother.connect_to(sibling, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas, demand: 20) }
  let!(:sc_edge) { sibling.connect_to(child, :gas) }
  let!(:fs_edge) { father.connect_to(sibling, :gas) }

  before do
    mother.set(:demand, 100.0)
    father.set(:demand, 50.0)
    child.set(:demand, 150.0)
    calculate!
  end

  it 'sets child demand' do
    expect(child).to have_demand.of(150.0)
  end

  it 'sets sibling demand' do
    expect(sibling).to have_demand.of(130.0)
  end

  it 'sets M->S demand' do
    expect(ms_edge).to have_demand.of(80.0)
  end

  it 'sets F->S demand' do
    expect(fs_edge).to have_demand.of(50.0)
  end

  it 'sets S->C demand' do
    expect(sc_edge).to have_demand.of(130.0)
  end

  it 'sets M->S share' do
    expect(ms_edge).to have_child_share.of(80.0 / 130)
  end

  it 'sets F->S share' do
    expect(fs_edge).to have_child_share.of(50.0 / 130)
  end

  it 'sets S->C share' do
    expect(sc_edge).to have_child_share.of(130.0 / 150)
  end

  it { expect(graph).to validate }
end # Graph calculations; with a sibling which is also a parent
