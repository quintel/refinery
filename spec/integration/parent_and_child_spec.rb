require 'spec_helper'

describe 'Graph calculations; a parent and child' do
  let!(:mother) { graph.add Turbine::Node.new(:mother) }
  let!(:child)  { graph.add Turbine::Node.new(:child) }

  context 'demand set on parent' do
    #   (45) [M]
    #         |
    #        [C]
    before do
      mother.set(:expected_demand, 45.0)
    end

    context 'and the edge has a share' do
      let!(:edge) { mother.connect_to(child, :gas, share: 1.0) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(45.0)
      end
    end

    context 'and the edge has no share' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(45.0)
      end

      it 'sets the edge share' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end
  end # demand set on parent

  context 'demand set on child' do
    #        [M]
    #         |
    #   (45) [C]
    before do
      child.set(:preset_demand, 45.0)
    end

    context 'and the edge has a share' do
      let!(:edge) { mother.connect_to(child, :gas, share: 1.0) }

      before { calculate! }

      it 'sets parent demand' do
        expect(demand(mother)).to eql(45.0)
      end
    end

    context 'and the edge has no share' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(demand(mother)).to eql(45.0)
      end

      it 'sets the edge share' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end

    context 'and the child demand exceeds parent supply' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before do
        mother.set(:expected_demand, 1.0)
        child.set(:preset_demand, 2.0)
        calculate!
      end

      it 'sets the edge share, not exceeding 1.0' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end
  end # demand set on child

  context 'no demand set' do
    #        [M]
    #         |
    #        [C]
    let!(:edge) { mother.connect_to(child, :gas) }
    before { calculate! }

    it 'sets the edge share' do
      expect(edge.get(:share)).to eql(1.0)
    end

    it 'does not set child demand' do
      expect(demand(child)).to be_nil
    end

    it 'does not set parent demand' do
      expect(demand(mother)).to be_nil
    end
  end # no demand set

  context 'with parallel edges using different carriers' do
    #         [M]
    #    :gas | | :electricity
    #         [C]
    let!(:mc_gas_edge)  { mother.connect_to(child, :gas) }
    let!(:mc_elec_edge) { mother.connect_to(child, :electricity) }
    before { calculate! }

    it 'sets the gas share to 1.0' do
      pending do
        expect(mc_gas_edge.get(:share)).to eql(1.0)
      end
    end

    it 'sets the electricity share to 1.0' do
      pending do
        expect(mc_elec_edge.get(:share)).to eql(1.0)
      end
    end
  end # with parallel edges using different carriers

end # Graph calculations
