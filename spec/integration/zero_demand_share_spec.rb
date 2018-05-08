require 'spec_helper'


describe 'Graph calculations; with three children' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:child_2) { graph.add Refinery::Node.new(:child_2) }
  let!(:child_3) { graph.add Refinery::Node.new(:child_3) }

  context 'with the same carriers' do
    let!(:mc1_edge) { child.connect_to(mother, :electricity) }
    let!(:mc2_edge) { child_2.connect_to(mother, :gas) }
    let!(:mc3_edge) { child_3.connect_to(mother, :superpowers) }

    context 'when the parent is missing demand' do
      #                        [M]
      #                      / / \
      #           __________/ /   \
      #          /           /     \
      #    (0) [C1]    (0) [C2]   [C3] (0)
      before do
        child.set(:demand, 0)
        child_2.set(:demand, 0)
        child_3.set(:demand, 0)
        calculate!
      end

      it 'sets demand for the parent' do
        expect(mother).to have_demand.of(0.0)
      end

      it 'sets slot shares' do
        expect(mother.slots.in.map { |slot| slot.share }).to eq([
          (1.0/3.0), (1.0/3.0), (1.0/3.0)
        ])
      end

      it { expect(graph).to validate }
    end
  end
end
