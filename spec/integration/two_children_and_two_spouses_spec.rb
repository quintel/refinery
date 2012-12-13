require 'spec_helper'

describe 'Graph calculations; two children and two spouses' do
  let!(:mother)   { graph.add Turbine::Node.new(:mother) }
  let!(:child)    { graph.add Turbine::Node.new(:child) }
  let!(:spouse_a) { graph.add Turbine::Node.new(:spouse_a) }
  let!(:spouse_b) { graph.add Turbine::Node.new(:spouse_b) }
  let!(:child_y)  { graph.add Turbine::Node.new(:child_y, preset_demand: 20.0) }
  let!(:child_z)  { graph.add Turbine::Node.new(:child_z, preset_demand: 55.0) }

  let!(:ay_edge)  { spouse_a.connect_to(child_y, :gas, share: 1.0) }
  let!(:my_edge)  { mother.connect_to(child_y, :gas, share: 0.2) }
  let!(:mz_edge)  { mother.connect_to(child_z, :gas, share: 0.8) }
  let!(:bz_edge)  { spouse_b.connect_to(child_z, :gas, share: 1.0) }

  context 'when spouses have no demand defined' do
    #    [A]     [M]     [B]
    #      \     / \     /
    #       \   /   \   /
    #        \ /     \ /
    #   (20) [Y]     [Z] (55)
    before do
      calculate!
    end

    it 'does not set demand' do
      # It is not possible to determine the demand of M without knowing
      # how much is supplied by A and B.
      expect(demand(spouse_a)).to be_nil
      expect(demand(mother)).to be_nil
      expect(demand(spouse_b)).to be_nil
    end
  end # when spouses have no demand defined

  context 'when one spouse has no demand defined' do
    #  (10) [A]     [M]     [B]
    #         \     / \     /
    #          \   /   \   /
    #           \ /     \ /
    #      (20) [Y]     [Z] (55)
    before do
      spouse_a.set(:expected_demand, 10.0)
      calculate!
    end

    it 'does not set demand' do
      # It is not possible to determine the demand of M without knowing
      # how much is supplied by B.
      expect(demand(mother)).to be_nil
      expect(demand(spouse_b)).to be_nil
    end
  end # when one spouse has no demand defined

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
        expect(demand(mother)).to eql(50.0)
      end
    end

    context 'and edges do not have shares' do
      before do
        my_edge.set(:share, nil)
        mz_edge.set(:share, nil)
        calculate!
      end

      it 'sets demand' do
        expect(demand(mother)).to eql(50.0)
      end

      it 'sets the edge shares' do
        expect(my_edge.get(:share)).to eql(0.2)
        expect(mz_edge.get(:share)).to eql(0.8)
      end
    end
  end # when spouses have demand
end # Graph calculations; two children and two spouses
