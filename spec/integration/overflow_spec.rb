require 'spec_helper'

describe 'Graph calculations; overflowing energy' do
  %w( hvn mvn lvn solar consumer export ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  #   ┌─────┐    ┌────────┐
  #   │ HVN │ ─> │ EXPORT │
  #   └─────┘    └────────┘
  #      |
  #      v
  #   ┌─────┐
  #   | MVN |
  #   └─────┘
  #      |
  #      v
  #   ┌─────┐    ┌─────┐
  #   | LVN |    | SOL |
  #   └─────┘    └─────┘
  #       |        |
  #       v        v
  #      ┌──────────┐
  #      | CONSUMER |
  #      └──────────┘

  let!(:hm_edge) { hvn.connect_to(mvn, :electricity) }
  let!(:ml_edge) { mvn.connect_to(lvn, :electricity) }
  let!(:lc_edge) { lvn.connect_to(consumer, :electricity) }
  let!(:sc_edge) { solar.connect_to(consumer, :electricity) }
  let!(:he_edge) { hvn.connect_to(export, :electricity) }

  context 'when the secondary supplier under-supplies' do
    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 80 of that, meaning the HVN needs to supply 20.
      solar.set(:demand, 80.0)

      # But the HVN supplies 120!
      hvn.set(:demand, 120.0)

      # Let's get this party started!
      calculate!
    end

    it 'sets HVN->MVN to 20.0' do
      expect(hm_edge).to have_demand.of(20.0)
    end

    it 'sets MVN->LVN to 20.0' do
      expect(ml_edge).to have_demand.of(20.0)
    end

    it 'sets LVN->CONSUMER to 20.0' do
      expect(lc_edge).to have_demand.of(20.0)
    end

    it 'sets SOLAR->CONSUMER to 80.0' do
      expect(sc_edge).to have_demand.of(80.0)
    end

    it 'sets HVN->EXPORT to 100.0' do
      expect(he_edge).to have_demand.of(100.0)
    end

    it { expect(graph).to validate }
  end # when the secondary supplier undersupplies

  context 'when the secondary supplier fulfils demand exactly' do
    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 100 of that, meaning the HVN needs to supply nothing.
      solar.set(:demand, 100.0)

      # But, disaster! HVN supplies 50!
      hvn.set(:demand, 50.0)

      # Tune in next week to find out what happens!
      calculate!
    end

    it 'sets HVN->MVN to 0.0' do
      expect(hm_edge).to have_demand.of(0.0)
    end

    it 'sets MVN->LVN to 0.0' do
      expect(ml_edge).to have_demand.of(0.0)
    end

    it 'sets LVN->CONSUMER to 0.0' do
      expect(lc_edge).to have_demand.of(0.0)
    end

    it 'sets SOLAR->CONSUMER to 100.0' do
      expect(sc_edge).to have_demand.of(100.0)
    end

    it 'sets HVN->EXPORT to 50.0' do
      expect(he_edge).to have_demand.of(50.0)
    end

    it { expect(graph).to validate }
  end # when the secondary supplier fulfils demand exactly

  context 'when the secondary supplier exceeds consumer demand' do
    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 150 -- more than is required -- meaning the HVN needs
      # to supply nothing.
      solar.set(:demand, 150.0)

      # HVN then supplies an additional 50.
      hvn.set(:demand, 50.0)

      # Om-nom-nom.
      calculate!
    end

    it 'sets HVN->MVN to -50.0' do
      expect(hm_edge).to have_demand.of(-50.0)
    end

    it 'sets MVN->LVN to -50.0' do
      expect(ml_edge).to have_demand.of(-50.0)
    end

    it 'sets LVN->CONSUMER to -50.0' do
      expect(lc_edge).to have_demand.of(-50.0)
    end

    it 'sets SOLAR->CONSUMER to 150.0' do
      expect(sc_edge).to have_demand.of(150.0)
    end

    it 'sets HVN->EXPORT to 100.0' do
      expect(he_edge).to have_demand.of(100.0)
    end

    it { expect(graph).to validate }
  end # when the secondary supplier exceeds consumer demand

  context 'when the secondary supplier has a long chain' do
    #   ┌─────┐    ┌────────┐
    #   │ HVN │ ─> │ EXPORT │
    #   └─────┘    └────────┘
    #      |
    #      v
    #   ┌─────┐
    #   | MVN |
    #   └─────┘
    #      |
    #      v
    #   ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐
    #   | LVN |    | SOL | <─ | SO2 | <─ | SO3 | <─ | SO4 |
    #   └─────┘    └─────┘    └─────┘    └─────┘    └─────┘
    #       |        |
    #       v        v
    #      ┌──────────┐
    #      | CONSUMER |
    #      └──────────┘
    %w( so2 so3 so4 ).each do |key|
      let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
    end

    let!(:so2_edge) { so2.connect_to(solar, :electricity) }
    let!(:so3_edge) { so3.connect_to(so2, :electricity) }
    let!(:so4_edge) { so4.connect_to(so3, :electricity) }

    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 100 of that, meaning the HVN needs to supply 20.
      so4.set(:demand, 100.0)

      # But the HVN supplies 50!
      hvn.set(:demand, 50.0)

      # Let's get this party started!
      calculate!
    end

    it 'sets HVN->MVN to 0.0' do
      expect(hm_edge).to have_demand.of(0.0)
    end

    it 'sets MVN->LVN to 0.0' do
      expect(ml_edge).to have_demand.of(0.0)
    end

    it 'sets LVN->CONSUMER to 0.0' do
      expect(lc_edge).to have_demand.of(0.0)
    end

    it 'set SO4->SO3 to 100.0' do
      expect(so4_edge).to have_demand.of(100.0)
    end

    it 'set SO3->SO2 to 100.0' do
      expect(so3_edge).to have_demand.of(100.0)
    end

    it 'set SO2->SOLAR to 100.0' do
      expect(so2_edge).to have_demand.of(100.0)
    end

    it 'sets SOLAR->CONSUMER to 100.0' do
      expect(sc_edge).to have_demand.of(100.0)
    end

    it 'sets HVN->EXPORT to 50.0' do
      expect(he_edge).to have_demand.of(50.0)
    end

    it { expect(graph).to validate }
  end # when the secondary supplier has a long chain
end # Graph calculations; overflowing energy
