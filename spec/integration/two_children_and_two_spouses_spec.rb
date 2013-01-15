require 'spec_helper'

describe 'Graph calculations; two children and two spouses' do
  let!(:mother)   { graph.add Refinery::Node.new(:mother) }
  let!(:spouse_a) { graph.add Refinery::Node.new(:spouse_a) }
  let!(:spouse_b) { graph.add Refinery::Node.new(:spouse_b) }
  let!(:child_y)  { graph.add Refinery::Node.new(:child_y, preset_demand: 20.0) }
  let!(:child_z)  { graph.add Refinery::Node.new(:child_z, preset_demand: 55.0) }

  let!(:ay_edge)  { spouse_a.connect_to(child_y, :gas, share: 0.5) }
  let!(:my_edge)  { mother.connect_to(child_y, :gas, share: 0.5) }
  let!(:mz_edge)  { mother.connect_to(child_z, :gas, share: 40.0 / 55) }
  let!(:bz_edge)  { spouse_b.connect_to(child_z, :gas, share: 15.0 / 55) }

  context 'when spouses have no demand defined' do
    #    [A]     [M]     [B]
    #      \     / \     /
    #       \   /   \   /
    #        \ /     \ /
    #   (20) [Y]     [Z] (55)
    before do
      calculate!
    end

    it 'sets demand for the first parent' do
      expect(spouse_a).to have_demand.of(10.0)
    end

    it 'sets demand for the second parent' do
      expect(mother).to have_demand.of(50.0)
    end

    it 'sets demand for the third parent' do
      expect(spouse_b).to have_demand.of(15.0)
    end
  end # when spouses have no demand defined

  context 'when one child has no demand defined' do
    #  (10) [A]     [M]     [B]
    #         \     / \     /
    #          \   /   \   /
    #           \ /     \ /
    #      (20) [Y]     [Z]
    before do
      spouse_a.set(:expected_demand, 10.0)
      child_z.set(:preset_demand, nil)
      calculate!
    end

    it 'does not set demand' do
      # It is not possible to determine the demand of M without knowing
      # how much is supplied by B.
      expect(mother).to_not have_demand
      expect(spouse_b).to_not have_demand
    end
  end # when one spouse has no demand defined

  context 'when all the parents have demand' do
    #  (10) [A] (40)[M]     [B] (15)
    #         \     / \     /
    #          \   /   \   /
    #           \ /     \ /
    #           [Y]     [Z]
    before do
      spouse_a.set(:expected_demand, 10.0)
      mother.set(:expected_demand, 40.0)
      spouse_b.set(:expected_demand, 15.0)
      child_y.set(:preset_demand, nil)
      child_z.set(:preset_demand, nil)
    end

    it 'does not set demand for the first child' do
      expect(child_y).to_not have_demand
    end

    it 'does not set demand for the second child' do
      expect(child_z).to_not have_demand
    end
  end # when all the parents have demand

  context 'when spouses have demand' do
    #  (10) [A]     [M]     [B] (15)
    #         \     / \     /
    #          \   /   \   /
    #           \ /     \ /
    #      (20) [Y]     [Z] (55)
    before do
      spouse_a.set(:expected_demand, 10.0)
      spouse_b.set(:expected_demand, 15.0)
    end

    context 'and edges have shares' do
      before { calculate! }

      it 'sets demand' do
        expect(mother).to have_demand.of(50.0)
      end
    end

    context 'and edges do not have shares' do
      before do
        my_edge.set(:share, nil)
        mz_edge.set(:share, nil)
        ay_edge.set(:share, nil)
        bz_edge.set(:share, nil)

        calculate!
      end

      it 'sets demand' do
        expect(mother).to have_demand.of(50.0)
      end

      it 'sets the edge shares' do
        expect(my_edge).to have_share.of(0.5)
        expect(mz_edge).to have_share.of(40.0 / 55)
      end
    end
  end # when spouses have demand
end # Graph calculations; two children and two spouses
