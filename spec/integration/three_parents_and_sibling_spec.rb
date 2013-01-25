require 'spec_helper'

describe 'Graph calculations; three parents and a sibling' do
  [ :a, :b, :c, :x, :y ].each do |key|
    let(key) { graph.add Refinery::Node.new(key) }
  end

  context 'with a single carrier' do
    #      (10) [A]     [B] (75)   [C]
    #           / \     /          /
    #          /   \   / _________/
    #         /     \ / /
    #   (5) [X]     [Y] (100)

    let!(:ax_edge) { a.connect_to(x, :gas) }
    let!(:ay_edge) { a.connect_to(y, :gas) }
    let!(:by_edge) { b.connect_to(y, :gas) }
    let!(:cy_edge) { c.connect_to(y, :gas) }

    before do
      a.set(:demand,  10.0)
      b.set(:demand,  75.0)
      c.set(:demand,  20.0)
      x.set(:demand,   5.0)
      y.set(:demand, 100.0)
    end

    context 'with no edge shares' do
      before { calculate! }

      it 'sets A->X edge share' do
        expect(ax_edge).to have_child_share.of(1.0)
      end

      it 'sets A->Y edge share' do
        expect(ay_edge).to have_child_share.of(0.05)
      end

      it 'sets B->Y edge share' do
        expect(by_edge).to have_child_share.of(0.75)
      end

      it 'sets C->Y edge share' do
        expect(cy_edge).to have_child_share.of(0.2)
      end

      it { expect(graph).to validate }
    end

    context 'with child-sibling edge demands available' do
      # Explicitly tests related child edge demands are subtracted in
      # EdgeDemand::FromDemand#unfulfilled_demand.

      #      (10) [A]     [B] (75)   [C]
      #           / \     / (75)     /
      #          /   \   / _________/ (20)
      #         /     \ / /
      #   (5) [X]     [Y] (100)
      before do
        a.set(:demand,  15.0)

        by_edge.set(:demand, 75.0)
        cy_edge.set(:demand, 20.0)

        calculate!
      end

      it 'sets A->X edge share' do
        expect(ax_edge).to have_demand.of(5.0)
      end

      it 'sets A->Y edge share' do
        expect(ay_edge).to have_demand.of(5.0)
      end

      # [A] has oversupply.
      it { expect(graph).to_not validate }
    end

    context 'and a missing supplier demand' do
      before do
        c.set(:demand, nil)
        calculate!
      end

      it 'sets A->X edge share' do
        expect(ax_edge).to have_child_share.of(1.0)
      end

      it 'sets A->Y edge share' do
        expect(ay_edge).to have_child_share.of(0.05)
      end

      it 'sets B->Y edge share' do
        expect(by_edge).to have_child_share.of(0.75)
      end

      it 'sets C->Y edge share' do
        expect(cy_edge).to have_child_share.of(0.2)
      end

      it 'sets demand of the remaining parent' do
        expect(c).to have_demand.of(20.0)
      end

      it { expect(graph).to validate }
    end

    context 'and a grandparent supplying the [C] parent' do
      #                              [G] (20)
      #                               |
      #      (10) [A]     [B]        [C]
      #           / \     /          /
      #          /   \   / _________/
      #         /     \ / /
      #   (5) [X]     [Y] (100)
      let!(:g) { graph.add Refinery::Node.new(:g, demand: 20.0) }
      let!(:gc_edge) { g.connect_to(c, :gas) }

      before do
        # b.set(:demand, nil)
        c.set(:demand, nil)
        calculate!
      end

      it 'sets the value of [B]' do
        expect(b).to have_demand.of(75.0)
      end

      it 'sets the value of [C]' do
        expect(c).to have_demand.of(20.0)
      end

      it 'sets the value of G->C' do
        expect(gc_edge).to have_demand.of(20.0)
      end

      it { expect(graph).to validate }
    end
  end # with a single carrier

  context 'with parallel edges using different carriers' do
    #  (175) [A]   (100) [B]     [C]
    #          \___     // \     /
    #              \   //   \   /
    #               \ //     \ /
    #         (250) [X]      [Y] (125)

    let!(:ax_elec_edge) { a.connect_to(x, :electricity) }
    let!(:bx_elec_edge) { b.connect_to(x, :electricity) }
    let!(:bx_gas_edge)  { b.connect_to(x, :gas) }
    let!(:by_gas_edge)  { b.connect_to(y, :gas) }
    let!(:cy_gas_edge)  { c.connect_to(y, :gas) }

    before do
      a.set(:demand, 175.0)
      b.set(:demand, 100.0)
      x.set(:demand, 250.0)
      y.set(:demand, 125.0)

      b.slots.out(:gas).set(:share, 0.75)
      b.slots.out(:electricity).set(:share, 0.25)

      x.slots.in(:gas).set(:share, 0.2)
      x.slots.in(:electricity).set(:share, 0.8)

      calculate!
    end

    it 'sets the A->X elec edge demand' do
      expect(ax_elec_edge).to have_child_share.of(0.875)
      expect(ax_elec_edge).to have_demand.of(175.0)
    end

    it 'sets the B->X elec edge demand' do
      expect(bx_elec_edge).to have_child_share.of(0.125)
      expect(bx_elec_edge).to have_demand.of(25.0)
    end

    it 'sets the B->X gas edge demand' do
      expect(bx_gas_edge).to have_child_share.of(1.0)
      expect(bx_gas_edge).to have_demand.of(50.0)
    end

    it 'sets the B->Y gas edge demand' do
      expect(by_gas_edge).to have_child_share.of(25.0 / 125)
      expect(by_gas_edge).to have_demand.of(25.0)
    end

    it 'sets the C->Y gas edge demand' do
      expect(cy_gas_edge).to have_child_share.of(100.0 / 125)
      expect(cy_gas_edge).to have_demand.of(100.0)
    end

    it 'sets demand of the remaining parent' do
      expect(c).to have_demand.of(100.0)
    end

    it { expect(graph).to validate }
  end # with parallel edges using different carriers
end # Graph calculations; three parents and a sibling
