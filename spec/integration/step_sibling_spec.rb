require 'spec_helper'

describe 'Graph calculations; with two parents and a step sibling' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }
  let!(:father)  { graph.add Refinery::Node.new(:father) }

  let!(:ms_edge) { mother.connect_to(sibling, :gas) }
  let!(:mc_edge) { mother.connect_to(child, :gas) }
  let!(:fc_edge) { father.connect_to(child, :gas) }

  before do
    sibling.set(:preset_demand, 75.0)
    mother.set(:expected_demand, 100.0)
    child.set(:preset_demand, 125.0)
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
      expect(ms_edge.get(:share)).to eql(0.75)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge.get(:share)).to eql(0.25)
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end
  end # and all nodes have demand

  context 'and the parent has no demand' do
    #           [M]     [F] (100)
    #           / \     /
    #          /   \   /
    #         /     \ /
    #  (75) [S]     [C] (125)
    before do
      calculate!
    end

    it 'calculates parent demand' do
      expect(mother.demand).to eql(100.0)
    end

    it 'calculates M->S share' do
      expect(ms_edge.get(:share)).to eql(0.75)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge.get(:share)).to eql(0.25)
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end
  end # and the parent has no demand

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

    it 'calculates sibling demand' do
      expect(sibling.demand).to eql(75.0)
    end

    it 'calculates M->S share' do
      expect(ms_edge.get(:share)).to eql(0.75)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge.get(:share)).to eql(0.25)
    end

    it 'calculates F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end
  end # and the sibling has no demand

  context 'and the sibling has multiple carriers and no demand' do
    #     (100) [M]     [F] (100)
    #          // \     /
    #         //   \   /
    #        //     \ /
    #       [S]     [C] (125)
    #
    # [M] generates 95 gas energy and 5 electricity. [C] requires 25 gas from
    # [M], leaving 70 gas to be assigned to [S].
    let!(:ms_elec_edge) { mother.connect_to(sibling, :electricity) }

    before do
      sibling.set(:preset_demand, nil)

      # father.set(:expected_demand, 100.0)
      # child.set(:preset_demand, 125.0)

      mother.slots.out(:electricity).set(:share, 0.05)
      mother.slots.out(:gas).set(:share, 0.95)

      calculate!
    end

    it 'calculates sibling demand' do
      expect(sibling.demand).to eql(75.0)
    end

    it 'calculates M->S (gas) share' do
      expect(ms_edge.get(:share)).to be_within(1e-7).of(70.0 / 95.0)
      expect(ms_edge.demand).to eql(70.0)
    end

    it 'calculates M->S (electricity) share' do
      expect(ms_elec_edge.get(:share)).to eql(1.0)
      expect(ms_elec_edge.demand).to eql(5.0)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge.get(:share)).to eql(25.0 / 95.0)
      expect(mc_edge.demand).to eql(25.0)
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
      expect(mother.demand).to be_nil
      expect(sibling.demand).to be_nil
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
      expect(ms_edge.get(:share)).to eql(0.75)
      expect(mc_edge.get(:share)).to eql(0.25)
      expect(fc_edge.get(:share)).to eql(1.0)
    end

    it "sets the parent's demand" do
      expect(father.demand).to eql(100.0)
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
      expect(sibling.demand).to eql(50.0)
    end

    it 'sets the edge shares' do
      expect(ms_edge.get(:share)).to eql(0.5)
      expect(mc_edge.get(:share)).to eql(0.5)
      expect(fc_edge.get(:share)).to eql(1.0)
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
      expect(sibling.demand).to eql(25.0)
    end

    it 'sets the edge shares' do
      expect(ms_edge.get(:share)).to eql(0.25)
      expect(mc_edge.get(:share)).to eql(0.75)
      expect(fc_edge.get(:share)).to eql(0.5)
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
      expect(child.demand).to be_nil
    end

    it 'does not set demand for the second parent' do
      expect(father.demand).to be_nil
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

    it 'sets F->C share' do
      expect(fc_edge.get(:share)).to eql(1.0)
    end

    it 'does not set demand' do
      expect(sibling.demand).to be_nil
      expect(child.demand).to be_nil
    end
  end # and the child and sibling have no demand
end # Graph calculations; with two parents and a step-sibling
