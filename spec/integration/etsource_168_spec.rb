require 'spec_helper'

# The examples make use of "be_within" to account for floating point errors
# until Refinery starts making use of BigDecimal.
describe 'ETsource #168 stub graph' do
  let(:graph) { Refinery.load }

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
    expect(node(:fd_hh_gas)).
      to have_demand.of(node(:fd_hh_gas).get(:final_demand))

    expect(node(:fd_hh_gas)).
      to have_demand.of(node(:fd_hh_gas).get(:final_demand))
  end

  it 'calculates the preset demand for household gas descendants' do
    # preset edge share = 0.0
    expect(node(:cooling)).to have_demand.of(0.0)

    # preset edge share = 0.24
    expect(node(:hot_water)).to have_demand.of(86.832)

    # preset edge share = 0.03
    expect(node(:cooking)).to have_demand.of(10.854)

    # preset edge share = 0.73
    expect(node(:space_heating_gas)).
      to have_demand.of(264.114)
  end

  it 'calculates demand for space heating descendants' do
    # preset edge share = 0.1
    expect(node(:gas_heater)).to have_demand.of(26.4114)

    # preset edge share = 0.9
    expect(node(:combi_heater)).to have_demand.of(237.7026)

    # preset edge share = 0.0
    expect(node(:gas_heat_pump)).to have_demand.of(0.0)

    # preset edge share = 0.0
    expect(node(:gas_chp)).to have_demand.of(0.0)
  end

  it 'calculates the edge shares for industrial gas descendants' do
    # calculated edge share = 1.0
    expect(node(:burner)).to have_demand.of(266.6)

  end

  it 'calculates the preset demand of household heating' do
    # feeds from all of the outputs of space heating.
    expect(node(:ud_heating_hh)).to have_demand.of(264.114)
  end

  it 'calculates the preset demand of industrial heating' do
    # calculated edge share = 1.0
    expect(node(:ud_heating_ind)).to have_demand.of(266.6)
  end

  it 'calculates the edge shares for the main gas node to households' do
    edge = node(:fd_gas).out_edges.
      select { |edge| edge.to.key == :fd_hh_gas }.first

    # total demand of 628.4, households demand is 361.8
    expect(edge).to have_child_share.of(1.0)
  end

  it 'calculates the edge shares for the main gas node to industry' do
    edge = node(:fd_gas).out_edges.
      select { |edge| edge.to.key == :fd_ind_gas }.first

    # total demand of 628.4, industry demand is 266.6
    expect(edge).to have_child_share.of(1.0)
  end

  it 'calculates the expected demand for the main gas node gas' do
    # combines the demand of the two descendants: 361.8 and 266.6
    expect(node(:fd_gas)).to have_demand.of(628.4)
  end

  it 'calcualtes the output edge share of gas heating' do
    edge = node(:gas_heater).out_edges.
      select { |edge| edge.to.key == :ud_heating_hh }.first

    expect(edge).to have_child_share.of(0.1)
  end

  it 'calcualtes the output edge share of combi heaters' do
    edge = node(:combi_heater).out_edges.
      select { |edge| edge.to.key == :ud_heating_hh }.first

    expect(edge).to have_child_share.of(0.9)
  end

  it 'calcualtes the output edge share of gas heat pumps' do
    edge = node(:gas_heat_pump).out_edges.
      select { |edge| edge.to.key == :ud_heating_hh }.first

    expect(edge).to have_child_share.of(0.0)
  end

  it 'calcualtes the output edge share of gas CHPs' do
    edge = node(:gas_chp).out_edges.
      select { |edge| edge.to.key == :ud_heating_hh }.first

    expect(edge).to have_child_share.of(0.0)
  end

  it { expect(graph).to validate }
end # ETsource #168 stub graph
