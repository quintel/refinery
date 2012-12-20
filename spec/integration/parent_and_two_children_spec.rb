require 'spec_helper'

describe 'Graph calculations; parent and two children' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }

  context 'and the children have demand' do
    #          [M]
    #          / \
    #   (30) [C] [S] (20)
    before do
      child.set(:preset_demand, 30.0)
      sibling.set(:preset_demand, 20.0)
    end

    context 'with edge shares' do
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 1.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas, share: 1.0) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother.demand).to eql(50.0)
      end
    end

    context 'without edge shares' do
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother.demand).to eql(50.0)
      end

      it 'sets the edge shares' do
        expect(mc_edge.get(:share)).to eql(0.6)
        expect(ms_edge.get(:share)).to eql(0.4)
      end
    end
  end # and the children have demand

  context 'and only one child has demand' do
    context 'with edge shares' do
      #          [M]
      #    (0.4) / \ (0.6)
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.4) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas, share: 0.6) }

      before do
        child.set(:preset_demand, 30.0)
        calculate!
      end

      it 'sets parent demand' do
        expect(mother.demand).to eql(75.0)
      end

      it 'sets sibling demand' do
        expect(sibling.demand).to eql(45.0)
      end
    end

    context 'and no edge shares' do
      #          [M]
      #          / \
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before { calculate! }

      it 'does not set mother demand' do
        expect(mother.demand).to be_nil
      end

      it 'does not set sibling demand' do
        expect(sibling.demand).to be_nil
      end
    end
  end # and only one child has demand

  context 'and only one edge has a share' do
    #     (20) [M]
    #    (0.4) / \
    #        [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.4) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }

    before { calculate! }

    it 'sets the remaining share to the other edge' do
      expect(ms_edge.get(:share)).to eql(0.6)
    end
  end

  context 'and the parent has demand' do
    #         [M] (50)
    #   (0.6) / \ (0.4)
    #       [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.6) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas, share: 0.4) }

    before do
      mother.set(:expected_demand, 50.0)
      calculate!
    end

    it 'sets child demand' do
      expect(child.demand).to eql(30.0)
    end

    it 'sets sibling demand' do
      expect(sibling.demand).to eql(20.0)
    end
  end # and the parent has demand

  context 'and the edges use different carriers' do
    let!(:mc_gas_edge) { mother.connect_to(child, :gas) }
    let!(:ms_elec_edge) { mother.connect_to(sibling, :electricity) }

    before do
      mother.slots.out(:gas).set(:share, 0.6)
      mother.slots.out(:electricity).set(:share, 0.4)
    end

    context 'and the parent defines demand' do
      #         [M] (50)
      #    :gas / \ :electricity
      #       [C] [S]
      before do
        mother.set(:expected_demand, 50.0)
        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_gas_edge.get(:share)).to eql(1.0)
        expect(ms_elec_edge.get(:share)).to eql(1.0)
      end

      it 'sets child demand' do
        expect(child.demand).to eql(30.0)
      end

      it 'sets sibling demand' do
        expect(sibling.demand).to eql(20.0)
      end
    end # and the parent defines demand

    context 'and one of the children defines demand' do
      #           [M]
      #      :gas / \ :electricity
      #   (120) [C] [S]
      before do
        child.set(:preset_demand, 120.0)
        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_gas_edge.get(:share)).to eql(1.0)
        expect(ms_elec_edge.get(:share)).to eql(1.0)
      end

      it 'sets parent demand' do
        expect(mother.demand).to eql(200.0)
      end

      it 'sets sibling demand' do
        expect(sibling.demand).to eql(80.0)
      end
    end # and one of the children defines demand

    context 'and one of the children has parallel edges' do
      let!(:ms_gas_edge) { mother.connect_to(sibling, :gas) }

      before do
        mother.slots.out(:gas).set(:share, 0.6)
        mother.slots.out(:electricity).set(:share, 0.4)
      end

      context 'with demand' do
        #           [M] (200)
        #      :gas / \\ :electricity, :gas
        #   (100) [C]  [S]
        #
        # If we know that gas accounts for 60% of the output of the mother
        # node, and we also know that child receives 100 energy via gas, we
        # can figure out how much gas energy is still unassigned. This gets
        # assigned to the sibling, and the remaining 80 energy must therefore
        # by assigned to the electricity edge.
        before do
          mother.set(:expected_demand, 200.0)
          child.set(:preset_demand, 100.0)
          calculate!
        end

        it 'sets the M->S electricity edge share' do
          expect(ms_elec_edge.get(:share)).to eql(1.0)
        end

        it 'sets the M->C gas edge share' do
          expect(mc_gas_edge.get(:share)).to eql(100.0 / 120.0)
        end

        it 'sets the M->S gas edge share' do
          expect(ms_gas_edge.get(:share)).to be_within(1e-8).of(20.0 / 120.0)
        end

        it 'sets sibling demand' do
          expect(sibling.demand).to eql(100.0)
        end
      end # with demand

      context 'without demand' do
        #        [M] (200)
        #   :gas / \\ :electricity, :gas
        #      [C]  [S]
        before do
          mother.set(:expected_demand, 200.0)
          sibling.set(:preset_demand, nil)
          calculate!
        end

        it 'does not set gas edge shares' do
          expect(ms_gas_edge.get(:share)).to be_nil
          expect(mc_gas_edge.get(:share)).to be_nil
        end

        it 'does not set child demand' do
          expect(child.demand).to be_nil
        end

        it 'does not set sibling demand' do
          expect(sibling.demand).to be_nil
        end
      end # without demand

      context 'without parent demand' do
        #        [M]
        #   :gas / \\ :electricity, :gas
        #      [C]  [S] (100)
        before do
          mother.set(:expected_demand, nil)
          sibling.set(:preset_demand, 100.0)
          calculate!
        end

        it 'does not set the gas edge shares' do
          expect(mc_gas_edge.get(:share)).to be_nil
          expect(ms_gas_edge.get(:share)).to be_nil
        end

        it 'does not set child demand' do
          expect(child.demand).to be_nil
        end

        it 'does not set parent' do
          expect(mother.demand).to be_nil
        end
      end # without parent demand
    end # and one of the children has parallel edges
  end # and the edges use different carriers
end # Graph calculations; with two children
