require 'spec_helper'

describe 'Graph calculations; flexible edges' do
  %w( grandparent mother father child ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  let!(:gm_edge) { grandparent.connect_to(mother, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas) }
  let!(:fc_edge) { father.connect_to(child, :gas, type: :flexible) }

  context 'when [GRANDPARENT]=20 and [CHILD]=50' do
    #  (20) [G]
    #        |
    #       [M] [F]
    #         \ /
    #         [C] (50)
    before do
      grandparent.set(:demand, 20)
      child.set(:demand, 50)
      calculate!
    end

    it 'sets demand of [M] to 20' do
      expect(mother).to have_demand.of(20)
    end

    it 'sets demand of [F] to 30' do
      expect(father).to have_demand.of(30)
    end

    it { expect(graph).to validate }
  end # when [GRANDPARENT]=20 and [CHILD]=50

  context 'when [GRANDPARENT]=50 and [CHILD]=50' do
    #  (50) [G]
    #        |
    #       [M] [F]
    #         \ /
    #         [C] (50)
    before do
      grandparent.set(:demand, 50)
      child.set(:demand, 50)
      calculate!
    end

    it 'sets demand of [M] to 50' do
      expect(mother).to have_demand.of(50)
    end

    it 'sets demand of [F] to 0' do
      expect(father).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when [GRANDPARENT]=50 and [CHILD]=50

  context 'when [GRANDPARENT]=50' do
    #  (50) [G]
    #        |
    #       [M] [F]
    #         \ /
    #         [C]
    before do
      grandparent.set(:demand, 50)
      calculate!
    end

    it 'sets demand of [M] to 50' do
      expect(mother).to have_demand.of(50)
    end

    it 'does not set demand of [F]' do
      expect(father).to_not have_demand
    end

    it { expect(graph).to_not validate }
  end # when [GRANDPARENT]=50

  context 'when [CHILD]=50 and [CHILD]->[MOTHER]=0.8' do
    #      [G]
    #       |
    #      [M] [F]
    #  (0.8) \ /
    #        [C] (50)
    before do
      child.set(:demand, 50)
      mc_edge.set(:child_share, 0.8)
      calculate!
    end

    it 'sets demand of [M] to 40' do
      expect(mother).to have_demand.of(40)
    end

    it 'sets demand of [G] to 40' do
      expect(grandparent).to have_demand.of(40)
    end

    it 'sets demand of [F] to 10' do
      expect(father).to have_demand.of(10)
    end

    it { expect(graph).to validate }
  end # when [CHILD]=50 and [CHILD]->[MOTHER]=0.8
end # Graph calculations; flexible edges

describe 'Graph calculations; flexible edges with a solo overflow' do
  %w( supplier flexible core overflow ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  let!(:sc_edge) { supplier.connect_to(core, :gas) }
  let!(:fc_edge) { flexible.connect_to(core, :gas, type: :flexible) }
  let!(:co_edge) { core.connect_to(overflow, :gas, type: :overflow) }

  before do
    supplier.set(:demand, 0)
    calculate!
  end

  it 'sets demand of [CORE] to 0' do
    expect(core).to have_demand.of(0)
  end

    it 'sets demand of [OVERFLOW] to 0' do
    expect(overflow).to have_demand.of(0)
  end

  it 'sets demand of [FLEXIBLE] to 0' do
    expect(flexible).to have_demand.of(0)
  end
end # Graph calculations; flexible edges with a solo overflow

describe 'Graph calculations; flexible edges with overflows' do
  #
  #       ┌──────┐                ┌───────┐
  #       │ SINK │                │ INPUT │
  #       └──────┘ <─ ┌──────┐ <─ └───────┘
  #                   │ CORE │
  #   ┌──────────┐ <─ └──────┘ <─ ┌──────────┐
  #   │ OVERFLOW │                │ FLEXIBLE │
  #   └──────────┘                └──────────┘
  #
  %w( sink overflow core input flexible ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  let!(:ic_edge) { input.connect_to(core, :gas) }
  let!(:fc_edge) { flexible.connect_to(core, :gas, type: :flexible) }
  let!(:cs_edge) { core.connect_to(sink, :gas) }
  let!(:co_edge) { core.connect_to(overflow, :gas, type: :overflow) }

  context 'when [SINK]=150 and [INPUT]=100' do
    before do
      sink.set(:demand, 150)
      input.set(:demand, 100)
      calculate!
    end

    it 'sets demand of [CORE] to 150' do
      expect(core).to have_demand.of(150)
    end

    it 'sets demand of [OVERFLOW] to 0' do
      expect(overflow).to have_demand.of(0)
    end

    it 'sets demand of [FLEXIBLE] to 50' do
      expect(flexible).to have_demand.of(50)
    end

    it { expect(graph).to validate }
  end # when [SINK]=150 and [INPUT]=100

  context 'when [SINK]=75 and [INPUT]=100' do
    before do
      sink.set(:demand, 75)
      input.set(:demand, 100)
      calculate!
    end

    it 'sets demand of [CORE] to 100' do
      expect(core).to have_demand.of(100)
    end

    it 'sets demand of [OVERFLOW] to 25' do
      expect(overflow).to have_demand.of(25)
    end

    it 'sets demand of [FLEXIBLE] to 0' do
      expect(flexible).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when [SINK]=75 and [INPUT]=100
end # Graph calculations; flexible edges with overflows
