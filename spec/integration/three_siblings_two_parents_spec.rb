require 'spec_helper'

describe 'Graph calculations; three siblings and two parents' do
  #                (100) [A]     [B] (50)
  #                    / / \     /
  #         __________/ /   \   /
  #        /           /     \ /
  #  (10) [X]   (75) [Y]     [Z]
  [ :a, :b, :x, :y, :z ].each do |key|
    let(key) { graph.add Refinery::Node.new(key) }
  end

  let!(:ax_edge) { a.connect_to(x, :gas) }
  let!(:ay_edge) { a.connect_to(y, :gas) }
  let!(:az_edge) { a.connect_to(z, :gas) }
  let!(:bz_edge) { b.connect_to(z, :gas) }

  before do
    a.set(:expected_demand, 100.0)
    b.set(:expected_demand,  50.0)
    x.set(:preset_demand,    10.0)
    y.set(:preset_demand,    75.0)

    calculate!
  end

  it 'sets child demand' do
    expect(z.demand).to eql(65.0)
  end

  it 'sets A->X edge share' do
    expect(ax_edge.get(:share)).to eql(1.0)
  end

  it 'sets A->Y edge share' do
    expect(ay_edge.get(:share)).to eql(1.0)
  end

  it 'sets A->Z edge share' do
    expect(az_edge.get(:share)).to eql(15.0 / 65)
  end

  it 'sets B->Z edge share' do
    expect(bz_edge.get(:share)).to be_within(1e-9).of(50.0 / 65)
  end
end # Graph calculations; three siblings and two parents
