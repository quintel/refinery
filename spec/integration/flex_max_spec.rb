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
    #               | DISTRIB | (100)
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
    #               | DISTRIB |
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
