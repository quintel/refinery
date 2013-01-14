require 'spec_helper'

describe 'Graph calculations; with three children' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:child_2) { graph.add Refinery::Node.new(:child_2) }
  let!(:child_3) { graph.add Refinery::Node.new(:child_3) }

  context 'with the same carriers' do
    let!(:mc1_edge) { mother.connect_to(child, :gas) }
    let!(:mc2_edge) { mother.connect_to(child_2, :gas) }
    let!(:mc3_edge) { mother.connect_to(child_3, :gas) }

    context 'when the parent is missing demand' do
      #                        [M]
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
        expect(mother).to have_demand.of(225.0)
      end

      it 'sets edge demands' do
        expect(mc1_edge.demand).to eql(50.0)
        expect(mc2_edge.demand).to eql(75.0)
        expect(mc3_edge.demand).to eql(100.0)
      end
    end

    context 'when a child is missing demand' do
      #             (225) [M]
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
        expect(child).to have_demand.of(50.0)
      end

      it 'sets edge demands' do
        expect(mc1_edge.demand).to eql(50.0)
        expect(mc2_edge.demand).to eql(75.0)
        expect(mc3_edge.demand).to eql(100.0)
      end
    end # when a child is missing demand

    context 'when a child and parent are missing demand' do
      #                   [M]
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
        expect(mother).to_not have_demand
      end

      it 'does not set child demand' do
        expect(child).to_not have_demand
      end

      it 'does not set M->C1 demand' do
        expect(mc1_edge.demand).to be_nil
      end

      it 'sets M->C2 demand' do
        expect(mc2_edge.demand).to eql(75.0)
      end

      it 'sets M->C3 demand' do
        expect(mc3_edge.demand).to eql(100.0)
      end
    end # when a child and parent are missing demand
  end # with the same carriers

  context 'when the child is connected with a different carrier' do
    let!(:mc1_edge) { mother.connect_to(child, :electricity) }
    let!(:mc2_edge) { mother.connect_to(child_2, :gas) }
    let!(:mc3_edge) { mother.connect_to(child_3, :gas) }

    #                        [M]
    #        :electricity  / / \  :gas
    #           __________/ /   \
    #          /           /     \
    #   (50) [C1]  (75) [C2]   [C3] (100)
    before do
      child.set(:preset_demand, 50.0)
      child_2.set(:preset_demand, 75.0)
      child_3.set(:preset_demand, 100.0)

      mother.slots.out(:electricity).set(:share, 50.0 / 225.0)
      mother.slots.out(:gas).set(:share, 175.0 / 225.0)

      calculate!
    end

    it 'sets demand for the parent' do
      expect(mother).to have_demand.of(225.0)
    end

    it 'sets electricity edge demand' do
      expect(mc1_edge.demand).to eql(50.0)
    end

    it 'sets gas edge demand' do
      expect(mc2_edge.demand).to eql(75.0)
      expect(mc3_edge.demand).to eql(100.0)
    end
  end # when the child is connected with a different carrier
end # Graph calculations; with three children
