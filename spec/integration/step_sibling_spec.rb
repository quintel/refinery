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

    it 'calculates M->S demand' do
      expect(ms_edge).to have_demand.of(75.0)
    end

    it 'calculates M->C demand, accounting for supply from F' do
      expect(mc_edge).to have_demand.of(25.0)
    end

    it 'calculates F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
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

    it 'calculates M->S demand' do
      expect(ms_edge).to have_demand.of(75.0)
    end

    it 'calculates M->C demand, accounting for supply from F' do
      expect(mc_edge).to have_demand.of(25.0)
    end

    it 'calculates F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
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

    it 'calculates M->S demand' do
      expect(ms_edge).to have_demand.of(75.0)
    end

    it 'calculates M->C demand, accounting for supply from F' do
      expect(mc_edge).to have_demand.of(25.0)
    end

    it 'calculates F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
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

      mother.slots.out(:electricity).set(:share, 0.05)
      mother.slots.out(:gas).set(:share, 0.95)

      sibling.slots.in(:electricity).set(:share, 5.0 / 75)
      sibling.slots.in(:gas).set(:share, 70.0 / 75)

      calculate!
    end

    it 'calculates sibling demand' do
      expect(sibling).to have_demand.of(75.0)
    end

    it 'calculates M->S (gas) demand' do
      expect(ms_edge).to have_demand.of(70.0)
    end

    it 'calculates M->S (electricity) demand' do
      expect(ms_elec_edge).to have_demand.of(5.0)
    end

    it 'calculates M->C demand, accounting for supply from F' do
      expect(mc_edge.demand).to be_within(1e-9).of(25.0)
    end

    it 'calculates F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
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

    it 'does not set M->S demand' do
      expect(ms_edge.demand).to be_nil
    end

    it 'does not calculate M->C demand' do
      expect(mc_edge).to have_demand.of(25.0)
    end

    it 'calculates F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
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

    it 'sets edge demands' do
      expect(ms_edge).to have_demand.of(75.0)
      expect(mc_edge).to have_demand.of(25.0)
      expect(fc_edge).to have_demand.of(100.0)
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

    it 'sets the edge demands' do
      expect(ms_edge).to have_demand.of(50.0)
      expect(mc_edge).to have_demand.of(50.0)
      expect(fc_edge).to have_demand.of(75.0)
    end
  end # and the second parent is a partial supplier by demand

  context 'and the second parent is a partial supplier' do
    #     (100) [M]     [F] (100)
    #           / \     /
    #          /   \   / (50)
    #         /     \ /
    #       [S]     [C] (125)
    before do
      fc_edge.set(:demand, 50.0)
      sibling.set(:preset_demand, nil)
      calculate!
    end

    it 'sets the sibling demand' do
      expect(sibling).to have_demand.of(25.0)
    end

    it 'sets the edge demands' do
      expect(ms_edge).to have_demand.of(25.0)
      expect(mc_edge).to have_demand.of(75.0)
    end
  end # and the second parent is a partial supplier

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

    it 'does not set M->S demand' do
      expect(ms_edge.demand).to be_nil
    end

    it 'does not set M->C demand' do
      expect(mc_edge.demand).to be_nil
    end

    it 'sets F->C demand' do
      expect(fc_edge).to have_demand.of(100.0)
    end

    it 'does not set demand' do
      expect(sibling).to_not have_demand
      expect(child).to_not have_demand
    end
  end # and the child and sibling have no demand
end # Graph calculations; with two parents and a step-sibling
