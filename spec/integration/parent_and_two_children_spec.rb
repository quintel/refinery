require 'spec_helper'

describe 'Graph calculations; parent and two children' do
  let!(:mother)  { graph.add Refinery::Node.new(:mother) }
  let!(:child)   { graph.add Refinery::Node.new(:child) }
  let!(:sibling) { graph.add Refinery::Node.new(:sibling) }

  context 'and the children have demand' do
    before do
      child.set(:demand, 30.0)
      sibling.set(:demand, 20.0)
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

      # This graph does not validate because the edge demands are insufficient
      # to fulfil the demand of the "to" nodes. Doesn't matter, since what
      # we're testing in this context is that the [M] node calculates its
      # demand using the edges, and doesn't care about the status of its
      # children.
      it { expect(graph).to_not validate }
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
        expect(ms_edge).to have_child_share.of(1.0)
      end

      # Like the previous context, this graph will also fail validation since
      # the M->C edge doesn't satisfy demand of [C].
      it { expect(graph).to_not validate }
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
        expect(mc_edge).to have_child_share.of(1.0)
        expect(ms_edge).to have_child_share.of(1.0)
      end

      it { expect(graph).to validate }
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
        child.set(:demand, 30.0)
        calculate!
      end

      it 'sets parent demand' do
        expect(mother).to have_demand.of(32.0)
      end

      it 'sets sibling demand' do
        expect(sibling).to have_demand.of(20.0)
      end

      # Ditto, ditto, ditto...
      it { expect(graph).to_not validate }
    end

    context 'with only one edge shares' do
      #          [M]
      #     (12) / \
      #   (30) [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 12.0) }
      let!(:ms_edge) { mother.connect_to(sibling, :gas) }

      before do
        child.set(:demand, 30.0)
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

      it { expect(graph).to_not validate }
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

      it { expect(graph).to_not validate }
    end
  end # and only one child has demand

  context 'and only one edge has a demand' do
    #     (20) [M]
    #     (10) / \
    #        [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, demand: 10.0) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }

    before do
      mother.set(:demand, 20.0)
      calculate!
    end

    it 'sets M->S demand' do
      expect(ms_edge).to have_demand.of(10.0)
    end

    it 'sets demand of the child' do
      expect(child).to have_demand.of(10.0)
    end

    it 'sets demand of the sibling' do
      expect(sibling).to have_demand.of(10.0)
    end

    it { expect(graph).to validate }
  end

  context 'and the parent has demand' do
    #         [M] (50)
    #    (20) / \ (30)
    #       [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas, demand: 20.0) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas, demand: 30.0) }

    before do
      mother.set(:demand, 50.0)
      calculate!
    end

    it 'sets demand of the child' do
      expect(child).to have_demand.of(20.0)
    end

    it 'sets demand of the sibling' do
      expect(sibling).to have_demand.of(30.0)
    end

    it { expect(graph).to validate }
  end # and the parent has demand

  context 'and one edge has a parent share' do
    #           [M]
    #  (ps:0.6) / \
    #         [C] [S]
    let!(:mc_edge) { mother.connect_to(child, :gas) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }

    context 'but no parent demand' do
      before do
        mc_edge.set(:parent_share, 0.6)
        calculate!
      end

      it 'does not set M->C demand' do
        expect(mc_edge).to_not have_demand
      end

      it 'does not set M->S demand' do
        expect(ms_edge).to_not have_demand
      end

      it 'does not set child demand' do
        expect(child).to_not have_demand
      end

      it 'does not set sibling demand' do
        expect(sibling).to_not have_demand
      end

      it { expect(graph).to_not validate }
    end

    context 'and the parent has demand' do
      before do
        mother.set(:demand, 200.0)
        mc_edge.set(:parent_share, 0.6)
        calculate!
      end

      it 'sets M->C demand' do
        expect(mc_edge).to have_demand.of(120.0)
      end

      it 'sets M->S demand' do
        expect(ms_edge).to have_demand.of(80.0)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(120.0)
      end

      it 'sets sibling demand' do
        expect(sibling).to have_demand.of(80.0)
      end

      it { expect(graph).to validate }
    end
  end # and one edge has a parent share

  context 'and the edges use different carriers' do
    let!(:mc_gas_edge) { mother.connect_to(child, :gas) }
    let!(:ms_elec_edge) { mother.connect_to(sibling, :electricity) }

    before do
      mother.slots.out(:gas).set(:share, 0.6)
      mother.slots.out(:electricity).set(:share, 0.4)
    end

    context 'and the children have zero demand' do
      #         [M]
      #    :gas / \ :electricity
      #   (0) [C] [S] (0)
      before do
        mother.slots.out(:gas).set(:share, nil)
        mother.slots.out(:electricity).set(:share, nil)

        child.set(:demand, 0.0)
        sibling.set(:demand, 0.0)

        calculate!
      end

      it 'does not set the slot shares' do
        expect(mother.slots.out(:gas).share).to be_nil
        expect(mother.slots.out(:electricity).share).to be_nil
      end
    end

    context 'and the parent defines demand' do
      #         [M] (50)
      #    :gas / \ :electricity
      #       [C] [S]
      before do
        mother.set(:demand, 50.0)
        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_gas_edge).to have_child_share.of(1.0)
        expect(ms_elec_edge).to have_child_share.of(1.0)
      end

      it 'sets the edge demands' do
        expect(mc_gas_edge).to have_demand.of(30.0)
        expect(ms_elec_edge).to have_demand.of(20.0)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(30.0)
      end

      it 'sets sibling demand' do
        expect(sibling).to have_demand.of(20.0)
      end

      it { expect(graph).to validate }
    end # and the parent defines demand

    context 'and one of the children defines demand' do
      #           [M]
      #      :gas / \ :electricity
      #   (120) [C] [S]
      before do
        child.set(:demand, 120.0)
        calculate!
      end

      it 'sets M->C edge demand' do
        expect(mc_gas_edge).to have_demand.of(120.0)
      end

      it 'does sets M->S edge demand' do
        expect(ms_elec_edge).to have_demand.of(80.0)
      end

      it 'sets parent demand' do
        expect(mother).to have_demand.of(200.0)
      end

      it 'sets sibling demand' do
        expect(sibling).to have_demand.of(80.0)
      end

      it { expect(graph).to validate }
    end # and one of the children defines demand

    context 'and both children define demand' do
      #           [M]
      #      :gas / \ :electricity
      #   (120) [C] [S] (80)
      before do
        child.set(:demand, 120.0)
        sibling.set(:demand, 80.0)

        calculate!
      end

      it 'sets the edge demands' do
        expect(mc_gas_edge).to have_demand.of(120.0)
        expect(ms_elec_edge).to have_demand.of(80.0)
      end

      it 'sets parent demand' do
        expect(mother).to have_demand.of(200.0)
      end

      it { expect(graph).to validate }
    end # and both children define demand

    context 'and the slot shares are unknown' do
      #         [M] (50)
      #    :gas / \ :electricity
      #       [C] [S]
      before do
        mother.set(:demand, 50.0)

        mother.slots.out(:gas).set(:share, nil)
        mother.slots.out(:electricity).set(:share, nil)

        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_gas_edge).to have_child_share.of(1.0)
        expect(ms_elec_edge).to have_child_share.of(1.0)
      end

      it 'does not attempt to calculate edge demands' do
        # Specifically asserts that the OnlyChild calculator does not run if
        # the slot share is not known.
        expect(mc_gas_edge.calculator).to_not be_calculated
        expect(ms_elec_edge.calculator).to_not be_calculated
      end

      it 'does not set the edge demands' do
        expect(mc_gas_edge).to_not have_demand
        expect(ms_elec_edge).to_not have_demand
      end

      it 'does not set child demand' do
        expect(child).to_not have_demand
      end

      it 'does not set sibling demand' do
        expect(sibling).to_not have_demand
      end

      it { expect(graph).to_not validate }
    end # and the slot shares are unknown

    context 'and one slot share is known, the other is elastic' do
      #              [M] (50)
      #   (0.4) :gas / \ :electricity (elastic)
      #            [C] [S]
      before do
        mother.set(:demand, 50.0)

        mother.slots.out(:gas).set(:share, 0.4)
        mother.slots.out(:electricity).set(:share, nil)
        mother.slots.out(:electricity).set(:type, :elastic)

        calculate!
      end

      it 'sets the edge demands' do
        expect(mc_gas_edge).to have_demand.of(20.0)
        expect(ms_elec_edge).to have_demand.of(30.0)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(20.0)
      end

      it 'sets sibling demand' do
        expect(sibling).to have_demand.of(30.0)
      end

      it { expect(graph).to validate }
    end # and one slot share is known, the other is elastic

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
          mother.set(:demand, 200.0)
          child.set(:demand, 100.0)
          calculate!
        end

        it 'sets the M->S electricity edge share' do
          expect(ms_elec_edge).to have_child_share.of(1.0)
        end

        it 'sets the M->S electricity edge demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'sets the M->C gas edge share' do
          expect(mc_gas_edge).to have_child_share.of(1.0)
        end

        it 'sets the M->C gas edge demand' do
          expect(mc_gas_edge).to have_demand.of(100.0)
        end

        it 'sets the M->S gas edge share' do
          expect(ms_gas_edge).to have_child_share.of(1.0)
        end

        it 'sets the M->S gas edge demand' do
          expect(ms_gas_edge).to have_demand.of(20.0)
        end

        it 'sets sibling demand' do
          expect(sibling).to have_demand.of(100.0)
        end

        it { expect(graph).to validate }
      end # with demand

      context 'without demand' do
        #        [M] (200)
        #   :gas / \\ :electricity, :gas
        #      [C]  [S]
        before do
          mother.set(:demand, 200.0)
          sibling.set(:demand, nil)
          calculate!

          # Mother:
          #   120 total gas.
          #    80 total electricity.
          #
          # Sibling:
          #   80% electricity in
          #   20% gas in
          #
          # All mother electricity goes to sibling. Therefore 80 * 0.8 = 100
          # demand in total.
        end

        it 'sets M->S electricity edge demand' do
          expect(ms_elec_edge).to have_demand.of(80.0)
        end

        it 'sets M->S gas edge demand' do
          expect(ms_gas_edge).to have_demand.of(20.0)
        end

        it 'sets M->C gas edge demand' do
          expect(mc_gas_edge).to have_demand.of(100.0)
        end

        it 'sets child demand' do
          expect(child).to have_demand.of(100.0)
        end

        it 'does sets sibling demand' do
          expect(sibling).to have_demand.of(100.0)
        end

        it { expect(graph).to validate }
      end # without demand

      context 'without parent demand' do
        #        [M]
        #   :gas / \\ :electricity, :gas
        #      [C]  [S] (100)
        before do
          mother.set(:demand, nil)
          sibling.set(:demand, 100.0)
          calculate!
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

        it 'sets parent demand' do
          expect(mother).to have_demand.of(200.0)
        end

        it { expect(graph).to validate }
      end # without parent demand

      context 'without parent demand, but with an edge share' do
        #           [M]
        #      :gas / \\ :electricity, :gas
        #   (100) [C]  [S]
        before do
          mother.set(:demand, nil)
          child.set(:demand, 100)
          mc_gas_edge.set(:parent_share, Rational(100) / Rational(120))

          calculate!
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

        it 'sets parent demand' do
          expect(mother).to have_demand.of(200.0)
        end

        it { expect(graph).to validate }
      end # without parent demand, but wih an edge shaer

      context 'without parent demand and a grandparent' do
        #        [G] (200)
        #         |
        #        [M]
        #   :gas / \\ :electricity, :gas
        #      [C]  [S] (100)
        let!(:grandparent) { graph.add Refinery::Node.new(:grandparent) }
        let!(:gm_edge)     { grandparent.connect_to(mother, :gas) }

        before do
          grandparent.set(:demand, 200.0)
          mother.set(:demand, nil)
          sibling.set(:demand, 100.0)
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

        it { expect(graph).to validate }
      end # without parent demand and a grandparent
    end # and one of the children has parallel edges
  end # and the edges use different carriers
end # Graph calculations; with two children
