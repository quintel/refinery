require 'spec_helper'

describe 'Graph calculations; with two parents and a step sibling' do
  let!(:mother)  { graph.add Turbine::Node.new(:mother) }
  let!(:child)   { graph.add Turbine::Node.new(:child) }
  let!(:sibling) { graph.add Turbine::Node.new(:sibling) }
  let!(:father)  { graph.add Turbine::Node.new(:father) }

  let!(:ms_edge) { mother.connect_to(sibling, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas) }
  let!(:fc_edge) { father.connect_to(child, :gas) }

  before do
    sibling.set(:preset_demand, 75.0)
    mother.set(:expected_demand, 100.0)
    child.set(:preset_demand, 75.0)
    father.set(:expected_demand, 100.0)
  end

  context 'and all nodes have demand' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #  (75) [S]     [C] (125)
    before do
      calculate!
    end

    it 'calculates M->S share' do
      pending do
        expect(ms_edge.get(:share)).to eql(0.75)
      end
    end

    it 'calculates M->C share, accounting for supply from F' do
      pending do
        expect(mc_edge.get(:share)).to eql(0.25)
      end
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end
  end # and all nodes have demand

  context 'and the sibling has no demand' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #       [S]     [C] (125)
    before do
      sibling.set(:preset_demand, nil)
      calculate!
    end

    it 'calculates M->S share' do
      pending do
        expect(ms_edge.get(:share)).to eql(0.75)
      end
    end

    it 'calculates M->C share, accounting for supply from F' do
      pending do
        expect(mc_edge.get(:share)).to eql(0.25)
      end
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end
  end # and the sibling has no demand

  context 'and the parent and sibling have no demand' do
    #           [M]     [F] (100)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #       [S]     [C] (125)
    before do
      sibling.set(:preset_demand, nil)
      mother.set(:expected_demand, nil)
      calculate!
    end

    it 'does not calculate  M->S share' do
      expect(ms_edge.get(:share)).to be_nil
    end

    it 'does not calculate M->C share' do
      expect(ms_edge.get(:share)).to be_nil
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end

    it 'does not calculate sibling or parent demand' do
      expect(demand(mother)).to be_nil
      expect(demand(sibling)).to be_nil
    end
  end # and the parent and sibling have no demand

  context 'and the second parent has no demand' do
    #     (100) [M]     [F]
    #           / \     /
    #          /   \   /
    #         /     \ /
    #  (75) [S]     [C] (125)
    before do
      father.set(:expected_demand, nil)
      calculate!
    end

    it 'sets edge shares' do
      pending do
        expect(ms_edge.get(:share)).to eql(1.0)
        expect(mc_edge.get(:share)).to eql(0.25)
        expect(fc_edge.get(:share)).to eql(1.0)
      end
    end

    it "sets the parent's demand" do
      pending do
        expect(demand(father)).to eql(100)
      end
    end
  end # and the second parent has no demand

  context 'and the second parent is a partial supplier by demand' do
    #     (100) [M]     [F] (75)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #       [S]     [C] (125)
    before do
      father.set(:expected_demand, 75.0)
      sibling.set(:preset_demand, nil)
      calculate!
    end

    it 'sets the sibling demand' do
      pending do
        expect(demand(sibling)).to eql(50.0)
      end
    end

    it 'sets the edge shares' do
      pending do
        expect(ms_edge.get(:share)).to eql(0.5)
        expect(mc_edge.get(:share)).to eql(0.5)
        expect(fc_edge.get(:share)).to eql(1.0)
      end
    end
  end # and the second parent is a partial supplier by demand

  context 'and the second parent is a partial supplier by share' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   / (0.5)
    #         /     \ /
    #       [S]     [C] (125)
    before do
      fc_edge.set(:share, 0.5)
      sibling.set(:preset_demand, nil)
      calculate!
    end

    it 'sets the sibling demand' do
      pending do
        expect(demand(sibling)).to eql(25.0)
      end
    end

    it 'sets the edge shares' do
      pending do
        expect(ms_edge.get(:share)).to eql(0.25)
        expect(mc_edge.get(:share)).to eql(0.75)
        expect(fc_edge.get(:share)).to eql(1.0)
      end
    end
  end # and the second parent is a partial supplier by share

  context 'and the child and second parent have no demand' do
    #     (100) [M]     [F]
    #           / \     /
    #          /   \   /
    #         /     \ /
    #  (75) [S]     [C]
    before do
      child.set(:preset_demand, nil)
      father.set(:expected_demand, nil)
      calculate!
    end

    it 'does not set child demand' do
      expect(demand(child)).to be_nil
    end

    it 'does not set demand for the second parent' do
      expect(demand(father)).to be_nil
    end
  end # and the child and second parent have no demand

  context 'and the child and sibling have no demand' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #       [S]     [C]
    before do
      sibling.set(:preset_demand, nil)
      child.set(:preset_demand, nil)
      calculate!
    end

    it 'does not set M->S share' do
      expect(ms_edge.get(:share)).to be_nil
    end

    it 'does not set M->C share' do
      expect(mc_edge.get(:share)).to be_nil
    end

    it 'does not set F->C share' do
      pending do
        expect(fc_edge.get(:share)).to be_nil
      end
    end

    it 'does not set demand' do
      expect(demand(sibling)).to be_nil
      expect(demand(child)).to be_nil
    end
  end # and the child and sibling have no demand
end # Graph calculations; with two parents and a step-sibling