require 'spec_helper'

# The examples make use of "be_within" to account for floating point errors
# until Refinery starts making use of BigDecimal.
describe 'ETsource #179 stub graph' do
  let(:graph) { Refinery::Stub.etsource_179 }

  def node(key)
    graph.node(key)
  end

  before do
    Refinery::Reactor.new(
      Refinery::Catalyst::ConvertFinalDemand,
      Refinery::Catalyst::Calculators
    ).run(graph)
  end

  it 'sets expected demand on the final demand nodes' do
    expect(node(:fd_hh_gas).get(:expected_demand)).
      to eql(node(:fd_hh_gas).get(:final_demand))

    expect(node(:fd_hh_gas).get(:expected_demand)).
      to eql(node(:fd_hh_gas).get(:final_demand))
  end

  it 'calculates the preset demand for household gas descendants' do
    # preset edge share = 0.0
    expect(node(:cooling).get(:preset_demand)).to eql(0.0)

    # preset edge share = 0.24
    expect(node(:hot_water).get(:preset_demand)).to eql(86.832)

    # preset edge share = 0.03
    expect(node(:cooking).get(:preset_demand)).to eql(10.854)

    # preset edge share = 0.73
    expect(node(:space_heating_gas).get(:expected_demand)).to eql(264.114)
  end

  it 'does not set the expected demand for household gas descendants' do
    # Expected demand is not set since these nodes are leaves.
    expect(node(:cooling).get(:expected_demand)).to be_nil
    expect(node(:hot_water).get(:expected_demand)).to be_nil
    expect(node(:cooking).get(:expected_demand)).to be_nil
  end

  it 'calculates demand for space heating descendants' do
    # preset edge share = 0.1
    expect(node(:gas_heater).get(:expected_demand)).to eql(26.4114)

    # preset edge share = 0.5
    expect(node(:combi_heater).get(:expected_demand)).to eql(132.057)

    # preset edge share = 0.0
    expect(node(:gas_heat_pump).get(:expected_demand)).to eql(0.0)

    # preset edge share = 0.4
    expect(node(:gas_chp).get(:expected_demand)).to eql(105.6456)
  end

  it 'calculates the edge shares for industrial gas descendants' do
    # calculated edge share = 1.0
    expect(node(:burner).get(:expected_demand)).to eql(266.6)
  end

  it 'calculates the preset demand of household heating' do
    # feeds from all of the outputs of space heating.
    expect(node(:ud_heating_hh).get(:preset_demand)).
      to be_within(1e-3).of(332.42)

    # expected demand is not set on leaf nodes.
    expect(node(:ud_heating_hh).get(:expected_demand)).to be_nil
  end

  it 'calculates the preset demand of industrial heating' do
    # calculated edge share = 1.0
    expect(node(:ud_heating_ind).get(:preset_demand)).to eql(266.6)

    # expected demand is not set on leaf nodes.
    expect(node(:ud_heating_ind).get(:expected_demand)).to be_nil
  end

  it 'calculates the edge shares for the main gas node to households' do
    edge = node(:fd_gas).out_edges.
      select { |edge| edge.to.key == :fd_hh_gas }.first

    # total demand of 628.4, households demand is 361.8
    expect(edge.get(:share)).to be_within(0.001).of(361.8 / 628.4)
  end

  it 'calculates the edge shares for the main gas node to industry' do
    edge = node(:fd_gas).out_edges.
      select { |edge| edge.to.key == :fd_ind_gas }.first

    # total demand of 628.4, industry demand is 266.6
    expect(edge.get(:share)).to be_within(0.001).of(266.6 / 628.4)
  end

  it 'calculates the expected demand for the main gas node gas' do
    # combines the demand of the two descendants: 361.8 and 266.6
    expect(node(:fd_gas).get(:expected_demand)).to be_within(0.001).of(628.4)
  end

  it 'does not overassign electricity demand' do
    expect(node(:locally_available_elec).get(:expected_demand)).to eql(100.0)
  end

  it 'fills needed electricity demand from the elec. network' do
    expect(node(:elec_network).get(:expected_demand)).
      to be_within(1e-4).of(76.923)
  end

  it 'propagates electricity demand to descendants of fd_elec' do
    expect(node(:fd_hh_elec).get(:expected_demand)).to eql(100.0)
    expect(node(:space_heating_elec).get(:expected_demand)).to eql(100.0)
    expect(node(:electric_heater).get(:expected_demand)).to eql(100.0)
  end
end # ETsource #179 stub graph
