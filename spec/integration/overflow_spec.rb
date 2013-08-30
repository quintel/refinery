require 'spec_helper'

describe 'Graph calculations; overflowing energy' do
  %w( source hvn mvn lvn solar consumer export ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  #   ┌────────┐
  #   │ SOURCE │
  #   └────────┘
  #      |
  #      v
  #   ┌─────┐    ┌────────┐
  #   │ HVN │ ─> │ EXPORT │
  #   └─────┘    └────────┘
  #     | ^
  #     v |
  #   ┌─────┐
  #   | MVN |
  #   └─────┘
  #     | ^
  #     v |
  #   ┌─────┐    ┌───────┐
  #   | LVN | <- | SOLAR |
  #   └─────┘    └───────┘
  #       |        |
  #       v        v
  #      ┌──────────┐
  #      | CONSUMER |
  #      └──────────┘

  let!(:ih_edge) { source.connect_to(hvn, :electricity) }
  let!(:hm_edge) { hvn.connect_to(mvn, :electricity) }
  let!(:ml_edge) { mvn.connect_to(lvn, :electricity) }
  let!(:lc_edge) { lvn.connect_to(consumer, :electricity) }
  let!(:sc_edge) { solar.connect_to(consumer, :electricity) }
  let!(:he_edge) { hvn.connect_to(export, :electricity, type: :overflow) }

  # Overflow edges.
  let!(:mh_edge) { mvn.connect_to(hvn, :electricity, type: :overflow) }
  let!(:lm_edge) { lvn.connect_to(mvn, :electricity, type: :overflow) }
  let!(:sl_edge) { solar.connect_to(lvn, :electricity, type: :overflow) }

  context 'when the secondary supplier under-supplies' do
    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 80 of that, meaning the HVN needs to supply 20.
      solar.set(:demand, 80.0)

      # But the SOURCE gives 120!
      source.set(:demand, 120.0)

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

    it 'sets SOLAR->LVN (overflow) to 0.0' do
      expect(sl_edge).to have_demand.of(0)
    end

    it 'sets LVN->MVN (overflow) to 0.0' do
      expect(lm_edge).to have_demand.of(0)
    end

    it 'sets MVN->HVN (overflow) to 0.0' do
      expect(mh_edge).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when the secondary supplier undersupplies

  context 'when the secondary supplier fulfils demand exactly' do
    before do
      # Consumer demands 100 energy.
      consumer.set(:demand, 100.0)

      # Solar provides 100 of that, meaning the HVN needs to supply nothing.
      solar.set(:demand, 100.0)

      # But, disaster! SOURCE gives 50!
      source.set(:demand, 50.0)

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

    it 'sets SOLAR->LVN (overflow) to 0.0' do
      expect(sl_edge).to have_demand.of(0)
    end

    it 'sets LVN->MVN (overflow) to 0.0' do
      expect(lm_edge).to have_demand.of(0)
    end

    it 'sets MVN->HVN (overflow) to 0.0' do
      expect(mh_edge).to have_demand.of(0)
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

      # SOURCE then gives an additional 50.
      source.set(:demand, 50.0)

      # Om-nom-nom.
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

    it 'sets HVN->EXPORT to 100.0' do
      expect(he_edge).to have_demand.of(100.0)
    end

    it 'sets SOLAR->LVN (overflow) to 50.0' do
      expect(sl_edge).to have_demand.of(50.0)
    end

    it 'sets LVN->MVN (overflow) to 50.0' do
      expect(lm_edge).to have_demand.of(50.0)
    end

    it 'sets MVN->HVN (overflow) to 50.0' do
      expect(mh_edge).to have_demand.of(50.0)
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

      # But the SOURCE provides 50!
      source.set(:demand, 50.0)

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

  context 'when HVN has a third child' do
    #   ┌──────┐    ┌─────┐    ┌────────┐
    #   │ SINK │ <─ │ HVN │ ─> │ EXPORT │
    #   └──────┘    └─────┘    └────────┘
    #                  |
    #                  v
    #               ┌─────┐
    #               | MVN |
    #               └─────┘
    #                  |
    #                  v
    #               ┌─────┐    ┌─────┐
    #               | LVN |    | SOL |
    #               └─────┘    └─────┘
    #                   |        |
    #                   v        v
    #                  ┌──────────┐
    #                  | CONSUMER |
    #                  └──────────┘
    #
    # This edge has a parent share of 0.3 -- the edge gets 30% of the demand
    # of HVN which is 50 -- the remaining amount *plus* the overflow from
    # SOLAR is assigned to EXPORT.
    #
    let!(:sink) { graph.add(Refinery::Node.new(:sink)) }
    let!(:sink_edge) { hvn.connect_to(sink, :electricity) }

    before do
      consumer.set(:demand, 100.0)
      solar.set(:demand, 150.0)
      source.set(:demand, 50.0)

      sink_edge.set(:parent_share, 0.3)

      calculate!
    end

    it 'sets HVN->EXPORT demand' do
      expect(he_edge).to have_demand.of(70.0)
    end

    it 'sets HVN->SINK demand' do
      expect(sink_edge).to have_demand.of(30.0)
    end
  end # when HVN has a third child

  context 'when the exporter has a second output slot' do
    #     ┌────────┐
    #     │ SOURCE │
    #     └────────┘
    #           |
    #           v
    #        ┌─────┐    ┌────────┐
    # ... <─ │ HVN │ ─> │ EXPORT │
    #        └─────┘    └────────┘
    #          | ^
    #          v |
    #          ...
    before do
      # Consumer demands 90 energy.
      consumer.set(:demand, 90.0)

      # Solar provides 0 of that, meaning the HVN needs to supply 90.
      solar.set(:demand, 0.0)

      # And the source provides exactly what is needed.
      source.set(:demand, 100.0)

      # ... because HVN loses 10% to loss.
      hvn.slots.out.get(:electricity).set(:share, 0.9)
      hvn.slots.out.add(:loss).set(:share, 0.1)

      # Here we go!
      calculate!
    end

    it 'sets HVN->MVN to 90.0' do
      expect(hm_edge).to have_demand.of(90.0)
    end

    it 'sets MVN->LVN to 90.0' do
      expect(ml_edge).to have_demand.of(90.0)
    end

    it 'sets LVN->CONSUMER to 90.0' do
      expect(lc_edge).to have_demand.of(90.0)
    end

    it 'sets SOLAR->CONSUMER to 0.0' do
      expect(sc_edge).to have_demand.of(0.0)
    end

    it 'sets HVN->EXPORT to 0.0' do
      expect(he_edge).to have_demand.of(0.0)
    end

    it 'sets SOLAR->LVN (overflow) to 0.0' do
      expect(sl_edge).to have_demand.of(0)
    end

    it 'sets LVN->MVN (overflow) to 0.0' do
      expect(lm_edge).to have_demand.of(0)
    end

    it 'sets MVN->HVN (overflow) to 0.0' do
      expect(mh_edge).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when the exporter has a second output slot
end # Graph calculations; overflowing energy

# Additional overflow examples, as described in quintel/refinery#5.
describe 'Graph calculations; overflowing energy (issue #5)' do
  %w( a b c x y z ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  #   ┌───┐    ┌───┐
  #   │ A │    │ X │
  #   └───┘    └───┘
  #     |        |
  #     v        v
  #   ┌───┐ ─> ┌───┐
  #   | B |    │ Y │
  #   └───┘ <─ └───┘
  #     |        |
  #     v        v
  #   ┌───┐    ┌───┐
  #   | C |    │ Z │
  #   └───┘    └───┘

  let!(:ab_edge) { a.connect_to(b, :gas) }
  let!(:bc_edge) { b.connect_to(c, :gas) }
  let!(:by_edge) { b.connect_to(y, :gas, type: :overflow) }

  let!(:xy_edge) { x.connect_to(y, :gas) }
  let!(:yb_edge) { y.connect_to(b, :gas) }
  let!(:yz_edge) { y.connect_to(z, :gas) }

  context 'when the primary supplier under-supplies' do
    #        ┌───┐    ┌───┐
    #  (200) │ A │    │ X │ (0)
    #        └───┘    └───┘
    #          |        |
    #          v        v
    #        ┌───┐ ─> ┌───┐
    #        | B |    │ Y │
    #        └───┘ <─ └───┘
    #          |        |
    #          v        v
    #        ┌───┐    ┌───┐
    #  (100) | C |    │ Z │
    #        └───┘    └───┘
    before do
      a.set(:demand, 200)
      c.set(:demand, 100)
      x.set(:demand, 0)

      calculate!
    end

    it 'sets A->B to 200' do
      expect(ab_edge).to have_demand.of(200)
    end

    it 'sets B->C to 100' do
      expect(bc_edge).to have_demand.of(100)
    end

    it 'sets B->Y to 100' do
      expect(by_edge).to have_demand.of(100)
    end

    it 'sets Y->B to 0' do
      expect(yb_edge).to have_demand.of(0)
    end

    it 'sets X->Y to 0' do
      expect(xy_edge).to have_demand.of(0)
    end

    it 'sets Y->Z to 100' do
      expect(yz_edge).to have_demand.of(100)
    end
  end # when the primary supplier over-supplies

  context 'when the primary supplier under-supplies' do
    #        ┌───┐    ┌───┐
    #  (100) │ A │    │ X │
    #        └───┘    └───┘
    #          |        |
    #          v        v
    #        ┌───┐ ─> ┌───┐
    #        | B |    │ Y │
    #        └───┘ <─ └───┘
    #          |        |
    #          v        v
    #        ┌───┐    ┌───┐
    #  (200) | C |    │ Z │
    #        └───┘    └───┘
    before do
      a.set(:demand, 100)
      c.set(:demand, 200)
      x.set(:demand, 0)

      calculate!
    end

    it 'sets A->B to 100' do
      expect(ab_edge).to have_demand.of(100)
    end

    it 'sets B->C to 200' do
      expect(bc_edge).to have_demand.of(200)
    end

    it 'sets B->Y to 0' do
      expect(by_edge).to have_demand.of(0)
    end

    it 'sets Y->B to 100' do
      expect(yb_edge).to have_demand.of(100)
    end

    it 'sets X->Y to 0' do
      expect(xy_edge).to have_demand.of(0)
    end

    it 'sets Y->Z to 0' do
      expect(yz_edge).to have_demand.of(0)
    end
  end # when the primary supplier under-supplies
end # Graph calculations; overflowing energy (issue #5)
