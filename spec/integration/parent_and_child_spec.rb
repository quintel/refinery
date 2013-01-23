require 'spec_helper'

describe 'Graph calculations; a parent and child' do
  let!(:mother) { graph.add Refinery::Node.new(:mother) }
  let!(:child)  { graph.add Refinery::Node.new(:child) }

  context 'demand set on parent' do
    #   (45) [M]
    #         |
    #        [C]
    before do
      mother.set(:expected_demand, 45.0)
    end

    context 'and the edge has demand' do
      let!(:edge) { mother.connect_to(child, :gas, demand: 45.0) }

      before { calculate! }

      it 'sets demand' do
        expect(child).to have_demand.of(45)
      end

      it { expect(graph).to validate }
    end

    context 'and the edge has no demand' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(child).to have_demand.of(45.0)
      end

      it 'sets the edge share' do
        expect(edge).to have_child_share.of(1.0)
      end

      it { expect(graph).to validate }
    end
  end # demand set on parent

  context 'demand set on child' do
    #        [M]
    #         |
    #   (45) [C]
    before do
      child.set(:preset_demand, 45.0)
    end

    context 'and the edge has demand' do
      let!(:edge) { mother.connect_to(child, :gas, demand: 45.0) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother).to have_demand.of(45.0)
      end

      it { expect(graph).to validate }
    end

    context 'and the edge has no demand' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother).to have_demand.of(45.0)
      end

      it 'sets the edge share' do
        expect(edge).to have_child_share.of(1.0)
      end

      it { expect(graph).to validate }
    end

    context 'and the child demand exceeds parent supply' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before do
        mother.set(:expected_demand, 1.0)
        child.set(:preset_demand, 2.0)
        calculate!
      end

      it 'sets the edge share, not exceeding 1.0' do
        expect(edge).to have_child_share.of(1.0)
      end

      it { expect(graph).to_not validate }
    end
  end # demand set on child

  context 'no demand set' do
    #        [M]
    #         |
    #        [C]
    let!(:edge) { mother.connect_to(child, :gas) }
    before { calculate! }

    it 'sets the edge demand' do
      expect(edge).to_not have_demand
    end

    it 'does not set child demand' do
      expect(child).to_not have_demand
    end

    it 'does not set parent demand' do
      expect(mother).to_not have_demand
    end

    it { expect(graph).to_not validate }
  end # no demand set

  context 'with parallel edges using different carriers' do
    #         [M]
    #    :gas | | :electricity
    #         [C]
    let!(:mc_gas_edge)  { mother.connect_to(child, :gas) }
    let!(:mc_elec_edge) { mother.connect_to(child, :electricity) }

    before do
      mother.slots.out(:gas).set(:share, 0.7)
      mother.slots.out(:electricity).set(:share, 0.3)

      child.slots.in(:gas).set(:share, 0.7)
      child.slots.in(:electricity).set(:share, 0.3)
    end

    context 'with demand defined on the child' do
      before do
        child.set(:preset_demand, 200.0)
        calculate!
      end

      it 'sets the gas share to 1.0' do
        expect(mc_gas_edge).to have_child_share.of(1.0)
      end

      it 'sets the electricity share to 1.0' do
        expect(mc_elec_edge).to have_child_share.of(1.0)
      end

      it 'sets parent demand' do
        expect(mother).to have_demand.of(200.0)
      end

      it 'can calculate demand passed through each edge' do
        expect(mc_gas_edge).to have_demand.of(140.0)
        expect(mc_elec_edge).to have_demand.of(60.0)
      end

      it { expect(graph).to validate }
    end # with demand defined on the child

    context 'with demand defined on the parent' do
      before do
        mother.set(:expected_demand, 100.0)
        calculate!
      end

      it 'sets the gas share to 1.0' do
        expect(mc_gas_edge).to have_child_share.of(1.0)
      end

      it 'sets the electricity share to 1.0' do
        expect(mc_elec_edge).to have_child_share.of(1.0)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(100.0)
      end

      it 'can calculate demand passed through each edge' do
        expect(mc_gas_edge).to have_demand.of(70.0)
        expect(mc_elec_edge).to have_demand.of(30.0)
      end

      it { expect(graph).to validate }
    end # with demand defined on the parent
  end # with parallel edges using different carriers

end # Graph calculations
