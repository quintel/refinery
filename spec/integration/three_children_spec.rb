require 'spec_helper'

describe 'Graph calculations; with three children' do
  let!(:mother)  { graph.add Turbine::Node.new(:mother) }
  let!(:child)   { graph.add Turbine::Node.new(:child) }
  let!(:child_2) { graph.add Turbine::Node.new(:child_2) }
  let!(:child_3) { graph.add Turbine::Node.new(:child_3) }

  let!(:mc1_edge) { mother.connect_to(child, :gas) }
  let!(:mc2_edge) { mother.connect_to(child_2, :gas) }
  let!(:mc3_edge) { mother.connect_to(child_3, :gas) }

  context 'when the parent is missing demand' do
    #                        [P]
    #                      / / \
    #           __________/ /   \
    #          /           /     \
    #   (50) [C1]   (75) [C2]   [C3] (100)
    before do
      child.set(:preset_demand, 50.0)
      child_2.set(:preset_demand, 75.0)
      child_3.set(:preset_demand, 100.0)
      calculate!
    end

    it 'sets demand for the parent' do
      expect(demand(mother)).to eql(225.0)
    end

    it 'sets edge shares' do
      expect(mc1_edge.get(:share)).to eql(50.0 / 225.0)
      expect(mc2_edge.get(:share)).to eql(75.0 / 225.0)
      expect(mc3_edge.get(:share)).to eql(100.0 / 225.0)
    end
  end

  context 'when a child is missing demand' do
    #             (225) [P]
    #                 / / \
    #      __________/ /   \
    #     /           /     \
    #   [C1]   (75) [C2]   [C3] (100)
    before do
      mother.set(:expected_demand, 225.0)
      child_2.set(:preset_demand, 75.0)
      child_3.set(:preset_demand, 100.0)
      calculate!
    end

    it 'sets demand for the child' do
      pending do
        expect(demand(child)).to eql(50.0)
      end
    end

    it 'sets edge shares' do
      expect(mc1_edge.get(:share)).to be_within(1e-8).of(50.0 / 225.0)
      expect(mc2_edge.get(:share)).to be_within(1e-8).of(75.0 / 225.0)
      expect(mc3_edge.get(:share)).to be_within(1e-8).of(100.0 / 225.0)
    end
  end # when a child is missing demand

  context 'when a child and parent are missing demand' do
    #                   [P]
    #                 / / \
    #      __________/ /   \
    #     /           /     \
    #   [C1]   (75) [C2]   [C3] (100)
    before do
      child_2.set(:preset_demand, 75.0)
      child_3.set(:preset_demand, 100.0)
      calculate!
    end

    it 'does not set parent demand' do
      expect(demand(mother)).to be_nil
    end

    it 'does not set child demand' do
      expect(demand(child)).to be_nil
    end

    it 'does not set edge shares' do
      expect(mc1_edge.get(:share)).to be_nil
      expect(mc2_edge.get(:share)).to be_nil
      expect(mc3_edge.get(:share)).to be_nil
    end
  end # when a child and parent are missing demand
end # Graph calcualtions; with three children
