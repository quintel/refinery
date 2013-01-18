require 'spec_helper'

describe 'Graph calculations; parent and two children' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }

  context 'and the children have demand' do
    before do
      child.set(:preset_demand, 30.0)
      sibling.set(:preset_demand, 20.0)
    end

    context 'with edge demands' do
      #          [M]
      #     (15) / \ (6)
      #   (30) [C] [S] (20)
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 15.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas, demand: 6.0) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother).to have_demand.of(21.0)
      end
    end

    context 'with only one edge demand' do
      #          [M]
      #     (15) / \
      #   (30) [C] [S] (20)
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 15.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother).to have_demand.of(35.0)
      end

      it 'sets the sibling edge share' do
        expect(ms_edge).to have_share.of(1.0)
      end
    end

    context 'without edge demands' do
      #          [M]
      #          / \
      #   (30) [C] [S] (20)
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(mother).to have_demand.of(50.0)
      end

      it 'sets the edge shares' do
        expect(mc_edge).to have_share.of(1.0)
        expect(ms_edge).to have_share.of(1.0)
      end
    end
  end # and the children have demand

  context 'and only one child has demand' do
    context 'with edge demands' do
      #          [M]
      #     (12) / \ (20)
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 12.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas, demand: 20.0) }

      before do
        child.set(:preset_demand, 30.0)
        calculate!
      end

      it 'sets parent demand' do
        expect(mother.demand).to eql(32.0)
      end

      it 'sets sibling demand' do
        expect(sibling.demand).to eql(20.0)
      end
    end

    context 'with only one edge shares' do
      #          [M]
      #     (12) / \
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 12.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before do
        child.set(:preset_demand, 30.0)
        calculate!
      end

      it 'does not set parent demand' do
        expect(mother).to_not have_demand
      end

      it 'does not set the sibling edge demand' do
        expect(ms_edge).to_not have_demand
      end

      it 'does not set sibling demand' do
        expect(sibling).to_not have_demand
      end
    end

    context 'and no edge demands' do
      #          [M]
      #          / \
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before { calculate! }

      it 'does not set mother demand' do
        expect(mother).to_not have_demand
      end

      it 'does not set sibling demand' do
        expect(sibling).to_not have_demand
      end
    end
  end # and only one child has demand

  context 'and only one edge has a demand' do
    #     (20) [M]
    #     (10) / \
    #        [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, demand: 10.0) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }

    before do
      mother.set(:expected_demand, 20.0)
      calculate!
    end

    it 'sets M->S demand' do
      expect(ms_edge.demand).to eql(10.0)
    end

    it 'sets demand of the child' do
      expect(child.demand).to eql(10.0)
    end

    it 'sets demand of the sibling' do
      expect(sibling.demand).to eql(10.0)
    end
  end

  context 'and the parent has demand' do
    #         [M] (50)
    #    (20) / \ (30)
    #       [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, demand: 20.0) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas, demand: 30.0) }

    before do
      mother.set(:expected_demand, 50.0)
      calculate!
    end

    it 'sets demand of the child' do
      expect(child.demand).to eql(20.0)
    end

    it 'sets demand of the sibling' do
      expect(sibling.demand).to eql(30.0)
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
        expect(mc_gas_edge).to have_share.of(1.0)
        expect(ms_elec_edge).to have_share.of(1.0)
      end

      it 'sets the edge demands' do
        expect(mc_gas_edge).to have_demand.of(30.0)
        expect(ms_elec_edge).to have_demand.of(20.0)
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

      it 'sets M->C edge demand' do
        expect(mc_gas_edge).to have_demand.of(120.0)
      end

      it 'does not set M->S edge demand' do
        expect(ms_elec_edge).to_not have_demand
      end

      it 'does not set parent demand' do
        expect(mother).to_not have_demand
      end

      it 'does not set sibling demand' do
        expect(sibling).to_not have_demand
      end
    end # and one of the children defines demand

    context 'and both children define demand' do
      #           [M]
      #      :gas / \ :electricity
      #   (120) [C] [S] (80)
      before do
        child.set(:preset_demand, 120.0)
        sibling.set(:preset_demand, 80.0)

        calculate!
      end

      it 'sets the edge demands' do
        expect(mc_gas_edge).to have_demand.of(120.0)
        expect(ms_elec_edge).to have_demand.of(80.0)
      end

      it 'sets parent demand' do
        expect(mother).to have_demand.of(200.0)
      end
    end # and both children define demand

    context 'and one of the children has parallel edges' do
      let!(:ms_gas_edge) { mother.connect_to(sibling, :gas) }

      before do
        mother.slots.out(:gas).set(:share, 0.6)
        mother.slots.out(:electricity).set(:share, 0.4)

        sibling.slots.in(:gas).set(:share, 0.2)
        sibling.slots.in(:electricity).set(:share, 0.8)
      end

      context 'with demand' do
        #           [M] (200)
        #      :gas / \\ :electricity, :gas
        #   (100) [C]  [S]
        before do
          mother.set(:expected_demand, 200.0)
          child.set(:preset_demand, 100.0)
          calculate!
        end

        it 'sets the M->S electricity edge share' do
          expect(ms_elec_edge).to have_share.of(1.0)
        end

        it 'sets the M->S electricity edge demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'sets the M->C gas edge share' do
          expect(mc_gas_edge).to have_share.of(1.0)
        end

        it 'sets the M->C gas edge demand' do
          expect(mc_gas_edge).to have_demand.of(100.0)
        end

        it 'sets the M->S gas edge share' do
          expect(ms_gas_edge).to have_share.of(1.0)
        end

        it 'sets the M->S gas edge demand' do
          expect(ms_gas_edge).to have_demand.of(20.0)
        end

        it 'sets sibling demand' do
          expect(sibling).to have_demand.of(100.0)
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

        it 'sets M->S electricity edge demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'does not set M->C gas edge demand' do
          expect(mc_gas_edge).to_not have_demand
        end

        it 'does not set M->S gas edge demand' do
          expect(ms_gas_edge).to_not have_demand
        end

        it 'does not set child demand' do
          expect(child).to_not have_demand
        end

        it 'does not set sibling demand' do
          expect(sibling).to_not have_demand
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

        it 'does not set M->C gas edge demand' do
          expect(mc_gas_edge).to_not have_demand
        end

        it 'sets M->S gas demand' do
          expect(ms_gas_edge).to have_demand.of(20.0)
        end

        it 'sets M->S electricity demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'does not set child demand' do
          expect(child).to_not have_demand
        end

        it 'does not set parent' do
          expect(mother).to_not have_demand
        end
      end # without parent demand

      context 'without parent demand and a grandparent' do
        #        [G] (200)
        #         |
        #        [M]
        #   :gas / \\ :electricity, :gas
        #      [C]  [S] (100)
        let!(:grandparent) { graph.add Refinery::Node.new(:grandparent) }
        let!(:gm_edge)     { grandparent.connect_to(mother, :gas) }

        before do
          grandparent.set(:expected_demand, 200.0)
          mother.set(:expected_demand, nil)
          sibling.set(:preset_demand, 100.0)
          calculate!
        end

        it 'sets parent demand' do
          expect(mother).to have_demand.of(200.0)
        end

        it 'sets M->C gas edge demand' do
          expect(mc_gas_edge).to have_demand.of(100.0)
        end

        it 'sets M->S gas demand' do
          expect(ms_gas_edge).to have_demand.of(20.0)
        end

        it 'sets M->S electricity demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'sets child demand' do
          expect(child).to have_demand.of(100.0)
        end
      end # without parent demand and a grandparent
    end # and one of the children has parallel edges
  end # and the edges use different carriers
end # Graph calculations; with two children
