require 'spec_helper'

# See: https://github.com/quintel/refinery/issues/25
describe 'Graph calculations; flex-max' do
  %w( a b x y d ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  let!(:ab_edge) { a.connect_to(b, :wood) }
  let!(:bd_edge) { b.connect_to(d, :wood, type: :flexible, priority: 1) }

  let!(:xd_edge) { x.connect_to(d, :wood, type: :flexible) }
  let!(:yd_edge) { y.connect_to(d, :wood) }

  context 'with max_demand on the flexible-edged node' do
    #           ┌───┐
    #           │ A │
    #           └───┘
    #             |
    #           ┌───┐  ┌───┐  ┌───┐        ││
    #  (md:10)  │ B │  │ X │  │ Y │ (50)   ││
    #           └───┘  └───┘  └───┘        vv
    #               \    |    /
    #               ┌─────────┐
    #               │ DISTRIB │ (100)
    #               └─────────┘
    before do
      b.set(:max_demand, 10)
      d.set(:demand,    100)
      y.set(:demand,     50)

      calculate!
    end

    it 'sets A->B to 10' do
      expect(ab_edge).to have_demand.of(10)
    end

    it 'sets B->D to 10' do
      expect(bd_edge).to have_demand.of(10)
    end

    it 'sets X->D to 40' do
      expect(xd_edge).to have_demand.of(40)
    end

    it 'sets Y->D to 50' do
      expect(yd_edge).to have_demand.of(50)
    end

    it { expect(graph).to validate }
  end # with max_demand on the flexible-edged node

  context 'with an undetermined demand on the child' do
    #           ┌───┐
    #           │ A │
    #           └───┘
    #             |
    #           ┌───┐  ┌───┐  ┌───┐    ││
    #  (md:10)  │ B │  │ X │  │ Y │    ││
    #           └───┘  └───┘  └───┘    vv
    #               \    |    /
    #               ┌─────────┐
    #               │ DISTRIB │
    #               └─────────┘
    before do
      b.set(:max_demand, 10)
      calculate!
    end

    it 'does not set A->B' do
      expect(ab_edge).to_not have_demand
    end

    it 'does not set B->D' do
      expect(bd_edge).to_not have_demand
    end

    it 'does not set X->D' do
      expect(xd_edge).to_not have_demand
    end

    it 'does not set Y->D' do
      expect(yd_edge).to_not have_demand
    end

    it 'does not set [DISTRIB]' do
      expect(d).to_not have_demand
    end

    it { expect(graph).to_not validate }
  end # with max_demand on the flexible-edged node
end # Graph calculations; flex-max

describe 'Graph calculations; recursive flex-max' do
  #         ┌───┐   ┌───┐
  #  (md:3) │ A │   │ B │ (md:7)
  #         └───┘   └───┘
  #             \  /
  #             ┌───┐
  #             │ M │
  #             └───┘                  ││
  #               │                    ││
  #             ┌───┐     ┌───┐        vv
  #             │ X │     │ Y │
  #             └───┘     └───┘
  #                 \     /
  #               ┌─────────┐
  #               │ CONSUME │ (100)
  #               └─────────┘
  %w( a b m x y c ).each do |key|
    let!(key.to_sym) { graph.add(Refinery::Node.new(key.to_sym)) }
  end

  let!(:am_edge) { a.connect_to(m, :gas, type: :flexible, priority: 2) }
  let!(:bm_edge) { b.connect_to(m, :gas, type: :flexible, priority: 1) }

  let!(:mx_edge) { m.connect_to(x, :gas, type: :flexible, priority: 1) }

  let!(:xc_edge) { x.connect_to(c, :gas, type: :flexible, priority: 1) }
  let!(:yc_edge) { y.connect_to(c, :gas, type: :flexible) }

  before do
    c.set(:demand, 100)
    a.set(:max_demand, 3)
    x.set(:max_demand, :recursive)
  end

  context 'when both parents have a max demand' do
    before do
      b.set(:max_demand, 7)
      calculate!
    end

    it 'sets A->M to 3' do
      expect(am_edge).to have_demand.of(3)
    end

    it 'sets B->M to 7' do
      expect(bm_edge).to have_demand.of(7)
    end

    it 'sets M->X to 10' do
      expect(mx_edge).to have_demand.of(10)
    end

    it 'sets Y->C to 90' do
      expect(yc_edge).to have_demand.of(90)
    end

    it { expect(graph).to validate }
  end # when both parents have a max demand

  context 'when demand is less than max_demand' do
    before do
      c.set(:demand, 2)
      b.set(:max_demand, 7)
      calculate!
    end

    it 'sets A->M to 2' do
      expect(am_edge).to have_demand.of(2)
    end

    it 'sets B->M to 0' do
      expect(bm_edge).to have_demand.of(0)
    end

    it 'sets M->X to 2' do
      expect(mx_edge).to have_demand.of(2)
    end

    it 'sets Y->C to 0' do
      expect(yc_edge).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when demand is less than max_demand

  context 'when one parent has no max demand' do
    before { calculate! }

    it 'does not set A->M' do
      expect(am_edge).to_not have_demand
    end

    it 'does not set B->M' do
      expect(bm_edge).to_not have_demand
    end

    it 'does not sets Y->C' do
      expect(yc_edge).to_not have_demand
    end

    it { expect(graph).to_not validate }
  end # when one parent has no max demand

  context 'when one parent is connected via a non-flex-max link' do
    before do
      bm_edge.set(:priority, nil)
      calculate!
    end

    it 'sets A->M to 3' do
      expect(am_edge).to have_demand.of(3)
    end

    it 'sets B->M to 97' do
      expect(bm_edge).to have_demand.of(97)
    end

    it 'sets M->X to 97' do
      expect(mx_edge).to have_demand.of(100)
    end

    it 'sets Y->C to 0' do
      expect(yc_edge).to have_demand.of(0)
    end

    it { expect(graph).to validate }
  end # when one parent has no max demand

  #         ┌───┐   ┌───┐
  #  (md:3) │ A │   │ B │ (md:7)
  #         └───┘   └───┘
  #             \  /
  #             ┌───┐
  #             │ M │
  #             └───┘                  ││
  #               │                    ││
  #             ┌───┐     ┌───┐        vv
  #             │ X │     │ Y │
  #             └───┘     └───┘
  #                 \     /
  #               ┌─────────┐
  #               │ CONSUME │ (100)
  #               └─────────┘
  context 'when the bridge edge is not flexible' do
    before do
      mx_edge.set(:priority, nil)
      mx_edge.set(:type, :share)

      b.set(:max_demand, 7)

      calculate!
    end

    it 'sets A->M to 3' do
      expect(am_edge).to have_demand.of(3)
    end

    it 'sets B->M to 7' do
      expect(bm_edge).to have_demand.of(7)
    end

    it 'sets M->X to 10' do
      expect(mx_edge).to have_demand.of(10)
    end

    it 'sets Y->C to 90' do
      expect(yc_edge).to have_demand.of(90)
    end

    it { expect(graph).to validate }
  end # when the bridge edge is not flexible
end # Graph calculations; recursive flex-max
