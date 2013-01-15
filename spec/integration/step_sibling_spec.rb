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
      expect(ms_edge).to have_share.of(1.0)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge).to have_share.of(25.0 / 125)
    end

    it 'calculates F->C share' do
      expect(fc_edge).to have_share.of(100.0 / 125)
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
      expect(mother).to have_demand.of(100.0)
    end

    it 'calculates M->S share' do
      expect(ms_edge).to have_share.of(1.0)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge).to have_share.of(25.0 / 125)
    end

    it 'calculates F->C share' do
      expect(fc_edge).to have_share.of(100.0 / 125)
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
      expect(sibling).to have_demand.of(75.0)
    end

    it 'calculates M->S share' do
      expect(ms_edge).to have_share.of(1.0)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge).to have_share.of(25.0 / 125)
    end

    it 'calculates F->C share' do
      expect(fc_edge).to have_share.of(100.0 / 125)
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

      sibling.slots.in(:electricity).set(:share, 0.05)
      sibling.slots.in(:gas).set(:share, 0.95)

      calculate!
    end

    it 'calculates sibling demand' do
      expect(sibling).to have_demand.of(75.0)
    end

    it 'calculates M->S (gas) share' do
      expect(ms_edge).to have_share.of(1.0)
      expect(ms_edge).to have_demand.of(75.0 * 0.95)
    end

    it 'calculates M->S (electricity) share' do
      expect(ms_elec_edge).to have_share.of(1.0)
      expect(ms_elec_edge).to have_demand.of(75.0 * 0.05)
    end

    it 'calculates M->C share, accounting for supply from F' do
      expect(mc_edge).to have_share.of(25.0 / 125.0)
      expect(mc_edge).to have_demand.of(25.0)
    end

    it 'calculates F->C share' do
      expect(fc_edge).to have_share.of(100.0 / 125.0)
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

    it 'does sets M->S share' do
      expect(ms_edge).to have_share.of(1.0)
    end

    it 'does not calculate M->C share' do
      expect(mc_edge).to have_share.of(25.0 / 125)
    end

    it 'calculates F->C share' do
      expect(fc_edge).to have_share.of(100.0 / 125)
    end

    it 'does not calculate sibling or parent demand' do
      expect(mother).to_not have_demand
      expect(sibling).to_not have_demand
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
      expect(ms_edge).to have_share.of(1.0)
      expect(mc_edge).to have_share.of(25.0 / 125)
      expect(fc_edge).to have_share.of(100.0 / 125)
    end

    it "sets the parent's demand" do
      expect(father).to have_demand.of(100.0)
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
      expect(sibling).to have_demand.of(50.0)
    end

    it 'sets the edge shares' do
      expect(ms_edge).to have_share.of(1.0)
      expect(mc_edge).to have_share.of(50.0 / 125)
      expect(fc_edge).to have_share.of(75.0 / 125)
    end
  end # and the second parent is a partial supplier by demand

  context 'and the second parent is a partial supplier by share' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   / (0.4)
    #         /     \ /
    #       [S]     [C] (125)
    before do
      fc_edge.set(:share, 0.4)
      sibling.set(:preset_demand, nil)
      calculate!
    end

    it 'sets the sibling demand' do
      expect(sibling).to have_demand.of(25.0)
    end

    it 'sets the edge shares' do
      expect(ms_edge).to have_share.of(1.0)
      expect(mc_edge).to have_share.of(0.6)
      expect(fc_edge).to have_share.of(0.4)
    end

    it 'calculates energy flowing through each edge' do
      expect(fc_edge).to have_demand.of(50.0)
      expect(mc_edge).to have_demand.of(75.0)
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
      expect(child).to_not have_demand
    end

    it 'does not set demand for the second parent' do
      expect(father).to_not have_demand
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

    it 'sets M->S share' do
      expect(ms_edge).to have_share.of(1.0)
    end

    it 'does not set M->C share' do
      expect(mc_edge.get(:share)).to be_nil
    end

    it 'does not set F->C share' do
      expect(fc_edge.get(:share)).to be_nil
    end

    it 'does not set demand' do
      expect(sibling).to_not have_demand
      expect(child).to_not have_demand
    end
  end # and the child and sibling have no demand
end # Graph calculations; with two parents and a step-sibling
