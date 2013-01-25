require 'spec_helper'

describe 'Graph calculations; efficiency' do
  context 'a chain of three nodes' do
    %w( top middle bottom ).each do |key|
      let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
    end

    let!(:tm_edge) { top.connect_to(middle, :gas) }
    let!(:mb_edge) { middle.connect_to(bottom, :gas) }

    before do
      middle.slots.out(:gas).set(:share, 0.6)
    end

    context 'when the top node has demand' do
      #   (50) [T]
      #         |
      #        [M]
      #         |
      #        [B]
      before do
        top.set(:demand, 50.0)
        calculate!
      end

      it 'sets demand of T->M' do
        expect(tm_edge).to have_demand.of(50.0)
      end

      it 'sets demand of [M]' do
        expect(middle).to have_demand.of(50.0)
      end

      it 'sets demand of M->B' do
        expect(mb_edge).to have_demand.of(30.0)
      end

      it 'sets demand of [B]' do
        expect(bottom).to have_demand.of(30.0)
      end

      it { expect(graph).to validate }
    end # when the top node has demand

    context 'when the bottom node has demand' do
      #        [T]
      #         |
      #        [M]
      #         |
      #   (50) [B]
      before do
        bottom.set(:demand, 30.0)
        calculate!
      end

      it 'sets demand of [T]' do
        expect(top).to have_demand.of(50.0)
      end

      it 'sets demand of T->M' do
        expect(tm_edge).to have_demand.of(50.0)
      end

      it 'sets demand of [M]' do
        expect(middle).to have_demand.of(50.0)
      end

      it 'sets demand of M->B' do
        expect(mb_edge).to have_demand.of(30.0)
      end

      it { expect(graph).to validate }
    end # when the bottom node has demand
  end # a chain of three nodes

  context 'a parent with two children' do
    %w( a x y ).each do |key|
      let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
    end

    context 'when the children have demand' do
      #          [A]
      #          / \
      #   (10) [X] [Y] (20)
      let!(:ax_edge) { a.connect_to(x, :gas) }
      let!(:ay_edge) { a.connect_to(y, :gas) }

      before do
        a.slots.out(:gas).set(:share, 0.5)

        x.set(:demand, 10.0)
        y.set(:demand, 20.0)

        calculate!
      end

      it 'sets demand of [A]' do
        expect(a).to have_demand.of(60.0)
      end

      it 'sets demand of A->X' do
        expect(ax_edge).to have_demand.of(10.0)
      end

      it 'sets demand of A->Y' do
        expect(ay_edge).to have_demand.of(20.0)
      end

      it { expect(graph).to validate }
    end # when the children have demand

    context 'with different carriers' do
      #               [A]
      #  :electricity / \ :gas
      #       (100) [X] [Y] (500)
      let!(:ax_edge) { a.connect_to(x, :electricity) }
      let!(:ay_edge) { a.connect_to(y, :gas) }

      before do
        a.slots.out(:gas).set(:share, 0.5)
        a.slots.out(:electricity).set(:share, 0.1)

        x.set(:demand, 200.0)
        y.set(:demand, 1000.0)

        calculate!
      end

      it 'sets demand of [A]' do
        expect(a).to have_demand.of(2000.0)
      end

      it 'sets demand of A->X' do
        expect(ax_edge).to have_demand.of(200.0)
      end

      it 'sets demand of A->Y' do
        expect(ay_edge).to have_demand.of(1000.0)
      end

      it { expect(graph).to validate }
    end # when one edge has demand
  end # a parent with two children

  context 'three parents and two children' do
    %w( a b c g x y ).each do |key|
      let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
    end

    #                              [G]
    #                               |
    #      (10) [A]     [B] (75)   [C]
    #           / \     /          /
    #          /   \   / _________/
    #         /     \ / /
    #   (5) [X]     [Y] (100)

    let!(:ax_edge) { a.connect_to(x, :gas) }
    let!(:ay_edge) { a.connect_to(y, :gas) }
    let!(:by_edge) { b.connect_to(y, :gas) }
    let!(:cy_edge) { c.connect_to(y, :gas) }
    let!(:gc_edge) { g.connect_to(c, :gas) }

    before do
      c.slots.out(:gas).set(:share, 0.5)
      g.slots.out(:gas).set(:share, 0.2)

      a.set(:demand,  10.0)
      b.set(:demand,  75.0)
      x.set(:demand,   5.0)
      y.set(:demand, 100.0)

      calculate!
    end

    it 'sets A->X demand' do
      expect(ax_edge).to have_demand.of(5.0)
    end

    it 'sets A->Y demand' do
      expect(ay_edge).to have_demand.of(5.0)
    end

    it 'sets B->Y demand' do
      expect(by_edge).to have_demand.of(75.0)
    end

    it 'sets C->Y demand' do
      expect(cy_edge).to have_demand.of(20.0)
    end

    it 'sets [C] demand' do
      expect(c).to have_demand.of(40.0)
    end

    it 'sets G->C demand' do
      expect(gc_edge).to have_demand.of(40.0)
    end

    it 'sets [G]' do
      expect(g).to have_demand.of(200.0)
    end
  end # three parents and two children
end # Graph calculations; efficiency
