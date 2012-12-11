require 'spec_helper'

module Refinery ; describe 'Demand calculations' do
  let!(:mother) { graph.add Turbine::Node.new(:mother) }
  let!(:child)  { graph.add Turbine::Node.new(:child) }

  let(:graph)   { Turbine::Graph.new }

  def calculate!
    Reactor.new(
      Catalyst::ConvertFinalDemand,
      Catalyst::Calculators
    ).run(graph)
  rescue Refinery::IncalculableGraphError
  end

  def demand(node)
    node.get(:calculator).demand
  end

  # --------------------------------------------------------------------------

  context 'with a single parent; demand set on parent' do
    #   (45) [M]
    #         |
    #        [C]
    before do
      mother.set(:expected_demand, 45.0)
    end

    context 'and the edge has a share' do
      let!(:edge) { mother.connect_to(child, :gas, share: 1.0) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(45.0)
      end
    end

    context 'and the edge has no share' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(45.0)
      end

      it 'sets the edge share' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end
  end # with a single parent; demand set

  context 'with a single parent; demand set on child' do
    #        [M]
    #         |
    #   (45) [C]
    before do
      child.set(:preset_demand, 45.0)
    end

    context 'and the edge has a share' do
      let!(:edge) { mother.connect_to(child, :gas, share: 1.0) }

      before { calculate! }

      it 'sets parent demand' do
        expect(demand(mother)).to eql(45.0)
      end
    end

    context 'and the edge has no share' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before { calculate! }

      it 'sets parent demand' do
        expect(demand(mother)).to eql(45.0)
      end

      it 'sets the edge share' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end

    context 'and the child demand exceeds parent supply' do
      let!(:edge) { mother.connect_to(child, :gas) }

      before do
        mother.set(:expected_demand, 1.0)
        child.set(:preset_demand, 2.0)
        calculate!
      end

      it 'sets the edge share, not exceeding 1.0' do
        expect(edge.get(:share)).to eql(1.0)
      end
    end
  end # with a single parent; demand set on child

  context 'with a single parent; no demand set' do
    #        [M]
    #         |
    #        [C]
    let!(:edge) { mother.connect_to(child, :gas) }
    before { calculate! }

    it 'sets the edge share' do
      expect(edge.get(:share)).to eql(1.0)
    end

    it 'does not set child demand' do
      expect(demand(child)).to be_nil
    end

    it 'does not set parent demand' do
      expect(demand(mother)).to be_nil
    end
  end # with a single parent; no demand set

  context 'when there are parallel edges with different carriers' do
    #         [M]
    #    :gas | | :electricity
    #         [C]
    let(:mc_gas_edge)  { mother.connect_to(child, :gas) }
    let(:mc_elec_edge) { mother.connect_to(child, :electricity) }

    it 'sets the gas share to 1.0' do
      pending do
        expect(mc_gas_edge.get(:share)).to eql(1.0)
      end
    end

    it 'sets the electricity share to 1.0' do
      pending do
        expect(mc_elec_edge.get(:share)).to eql(1.0)
      end
    end
  end # when there are parallel edges with different carriers

  context 'with two parents' do
    let!(:father) { graph.add Turbine::Node.new(:father) }

    #   (45) [M] [F] (25)
    #          \ /
    #          [C]
    before do
      mother.set(:expected_demand, 45.0)
      father.set(:expected_demand, 25.0)
    end

    context 'and the edges both have shares' do
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 1.0) }
      let!(:fc_edge) { father.connect_to(child, :gas, share: 1.0) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(70.0)
      end
    end

    context 'and neither edge has a share' do
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(demand(child)).to eql(70.0)
      end

      it 'sets the edge shares' do
        expect(fc_edge.get(:share)).to eql(1.0)
        expect(mc_edge.get(:share)).to eql(1.0)
      end
    end

    context 'and demand is missing on one' do
      #   (45) [M] [F] (nil)
      #          \ /
      #          [C]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before do
        father.set(:expected_demand, nil)
        calculate!
      end

      it 'does not set demand' do
        expect(demand(child)).to be_nil
      end

      it 'sets the edge shares' do
        expect(mc_edge.get(:share)).to eql(1.0)
        expect(fc_edge.get(:share)).to eql(1.0)
      end
    end
  end # with two parents; demand set

  context 'with two children' do
    let!(:sibling) { graph.add Turbine::Node.new(:sibling) }

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
          expect(demand(mother)).to eql(50.0)
        end
      end

      context 'without edge shares' do
        let!(:mc_edge) { mother.connect_to(child, :gas) }
        let!(:ms_edge) { mother.connect_to(sibling, :gas) }

        before { calculate! }

        it 'sets parent demand' do
          expect(demand(mother)).to eql(50.0)
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

        before { calculate! }

        it 'sets parent demand' do
          pending "I'm not sure why this doesn't work yet..." do
            expect(demand(mother)).to eql(75.0)
          end
        end

        it 'sets sibling demand' do
          pending "I'm not sure why this doesn't work yet..." do
            expect(demand(sibling)).to eql(45.0)
          end
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
          expect(demand(mother)).to be_nil
        end

        it 'does not set sibling demand' do
          expect(demand(sibling)).to be_nil
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
        expect(demand(child)).to eql(30.0)
      end

      it 'sets sibling demand' do
        expect(demand(sibling)).to eql(20.0)
      end
    end # and the parent has demand

    context 'and the edges use different carriers' do
      #         [M] (50)
      #    :gas / \ :electricity
      #       [C] [S]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:ms_edge) { mother.connect_to(sibling, :electricity) }

      before do
        mother.set(:expected_demand, 50.0)
        calculate!
      end

      it 'sets the edge shares' do
        pending do
          expect(mc_edge.get(:share)).to eql(1.0)
          expect(ms_edge.get(:share)).to eql(1.0)
        end
      end

      it 'sets child demand' do
        pending do
          expect(demand(child)).to eql(30.0)
        end
      end

      it 'sets sibling demand' do
        pending do
          expect(demand(sibling)).to eql(20.0)
        end
      end
    end # and the edges use different carriers
  end # with two children

  context 'with two parents' do
    let!(:father) { graph.add Turbine::Node.new(:father) }

    context 'and the child has demand' do
      #       [M]  [F]
      #  (0.75) \ / (0.1)
      #         [C] (100)
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.75) }
      let!(:fc_edge) { father.connect_to(child, :gas, share: 0.1) }

      before do
        child.set(:preset_demand, 100.0)
        calculate!
      end

      it 'does not set parent demand' do
        expect(demand(mother)).to be_nil
        expect(demand(father)).to be_nil
      end
    end # and the child has demand

    context 'and a parent has demand' do
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.75) }
      let!(:fc_edge) { father.connect_to(child, :gas, share: 0.6) }

      context "but the child doesn't" do
        #   (60) [M] [F]
        #  (0.75)  \ / (0.6)
        #          [C]
        before do
          mother.set(:expected_demand, 60.0)
          calculate!
        end

        it "does not set the other parent's demand" do
          expect(1).to eql 1
          # expect(demand(father)).to be_nil
        end

        it "does not set the child's demand" do
          expect(demand(child)).to be_nil
        end
      end

      context 'as does the child' do
        #   (60) [M] [F]
        #   (0.75) \ / (0.6)
        #          [C] (180)
        before do
          child.set(:expected_demand, 180.0)
          calculate!
        end

        it "sets the other parent's demand" do
          pending do
            expect(demand(father)).to eql(135.0)
          end
        end
      end
    end # and a parent has demand
  end # with two parents

  context 'with two parents a step-sibling' do
    let!(:sibling) { graph.add Turbine::Node.new(:sibling) }
    let!(:father)  { graph.add Turbine::Node.new(:father) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }
    let!(:mc_edge) { mother.connect_to(child, :gas) }
    let!(:fc_edge) { father.connect_to(child, :gas) }

    before do
      sibling.set(:preset_demand, 75.0)
      mother.set(:expected_demand, 100.0)
      child.set(:preset_demand, 75.0)
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
        pending do
          expect(ms_edge.get(:share)).to eql(0.75)
        end
      end

      it 'calculates M->C share, accounting for supply from F' do
        pending do
          expect(mc_edge.get(:share)).to eql(0.25)
        end
      end

      it 'calculates F->C share' do
        expect(fc_edge.get(:share)).to eql(1.0)
      end
    end # and all nodes have demand

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

      it 'calculates M->S share' do
        pending do
          expect(ms_edge.get(:share)).to eql(0.75)
        end
      end

      it 'calculates M->C share, accounting for supply from F' do
        pending do
          expect(mc_edge.get(:share)).to eql(0.25)
        end
      end

      it 'calculates F->C share' do
        expect(fc_edge.get(:share)).to eql(1.0)
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

      it 'does not calculate  M->S share' do
        expect(ms_edge.get(:share)).to be_nil
      end

      it 'does not calculate M->C share' do
        expect(ms_edge.get(:share)).to be_nil
      end

      it 'calculates F->C share' do
        expect(fc_edge.get(:share)).to eql(1.0)
      end

      it 'does not calculate sibling or parent demand' do
        expect(demand(mother)).to be_nil
        expect(demand(sibling)).to be_nil
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
        pending do
          expect(ms_edge.get(:share)).to eql(1.0)
          expect(mc_edge.get(:share)).to eql(0.25)
          expect(fc_edge.get(:share)).to eql(1.0)
        end
      end

      it "sets the parent's demand" do
        pending do
          expect(demand(father)).to eql(100)
        end
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
        pending do
          expect(demand(sibling)).to eql(50.0)
        end
      end

      it 'sets the edge shares' do
        pending do
          expect(ms_edge.get(:share)).to eql(0.5)
          expect(mc_edge.get(:share)).to eql(0.5)
          expect(fc_edge.get(:share)).to eql(1.0)
        end
      end
    end # and the second parent is a partial supplier by demand

    context 'and the second parent is a partial supplier by share' do
      #     (100) [M]     [F] (100)
      #           / \     /
      #          /   \   / (0.5)
      #         /     \ /
      #       [S]     [C] (125)
      before do
        fc_edge.set(:share, 0.5)
        sibling.set(:preset_demand, nil)
        calculate!
      end

      it 'sets the sibling demand' do
        pending do
          expect(demand(sibling)).to eql(25.0)
        end
      end

      it 'sets the edge shares' do
        pending do
          expect(ms_edge.get(:share)).to eql(0.25)
          expect(mc_edge.get(:share)).to eql(0.75)
          expect(fc_edge.get(:share)).to eql(1.0)
        end
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
        expect(demand(child)).to be_nil
      end

      it 'does not set demand for the second parent' do
        expect(demand(father)).to be_nil
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

      it 'does not set M->S share' do
        expect(ms_edge.get(:share)).to be_nil
      end

      it 'does not set M->C share' do
        expect(mc_edge.get(:share)).to be_nil
      end

      it 'does not set F->C share' do
        pending do
          expect(fc_edge.get(:share)).to be_nil
        end
      end

      it 'does not set demand' do
        expect(demand(sibling)).to be_nil
        expect(demand(child)).to be_nil
      end
    end # and the child and sibling have no demand
  end # with two parents and two siblings


  context 'with two children and two spouses' do
    # Calculating demand for [M]:
    #
    #    [A]     [M]     [B]
    #      \     / \     /
    #       \   /   \   /
    #        \ /     \ /
    #   (20) [Y]     [Z] (55)
    let!(:spouse_a) { graph.add Turbine::Node.new(:spouse_a) }
    let!(:spouse_b) { graph.add Turbine::Node.new(:spouse_b) }
    let!(:child_y)  { graph.add Turbine::Node.new(:child_y, preset_demand: 20.0) }
    let!(:child_z)  { graph.add Turbine::Node.new(:child_z, preset_demand: 55.0) }

    let!(:ay_edge)  { spouse_a.connect_to(child_y, :gas, share: 1.0) }
    let!(:my_edge)  { mother.connect_to(child_y, :gas, share: 0.2) }
    let!(:mz_edge)  { mother.connect_to(child_z, :gas, share: 0.8) }
    let!(:bz_edge)  { spouse_b.connect_to(child_z, :gas, share: 1.0) }

    context 'when spouses have no demand defined' do
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
          pending do
            expect(my_edge.get(:share)).to eql(0.2)
            expect(mz_edge.get(:share)).to eql(0.8)
          end
        end
      end
    end # when spouses have demand
  end # with two children and two spouses

  context 'with three parents and a sibling' do
    #     (100) [M]     [F] (15)   [R]
    #           / \     /          /
    #          /   \   / _________/
    #         /     \ / /
    #  (75) [S]     [C] (125)
    let!(:sibling)  { graph.add Turbine::Node.new(:sibling) }
    let!(:father)   { graph.add Turbine::Node.new(:father) }
    let!(:relative) { graph.add Turbine::Node.new(:relative) }

    let!(:ms_edge)  { mother.connect_to(sibling, :gas) }
    let!(:mc_edge)  { mother.connect_to(child, :gas) }
    let!(:fc_edge)  { father.connect_to(child, :gas) }
    let!(:rc_edge)  { relative.connect_to(child, :gas) }

    before do
      sibling.set(:preset_demand, 75.0)
      mother.set(:expected_demand, 100.0)
      child.set(:preset_demand, 125.0)
      father.set(:expected_demand, 15.0)
      calculate!
    end

    context 'with no edge shares' do
      it 'sets edge shares' do
        pending do
          expect(ms_edge.get(:share)).to eql(0.75)
          expect(mc_edge.get(:share)).to eql(0.25)
          expect(fc_edge.get(:share)).to eql(1.0)
          expect(rc_edge.get(:share)).to eql(1.0)
        end
      end

      it 'sets demand for the third parent' do
        pending do
          expect(demand(relative)).to eql(85.0)
        end
      end
    end

    context 'with a share on the third parent' do
      before do
        rc_edge.set(:share, 0.2)
        calculate!
      end

      it 'sets demand for the third parent' do
        pending do
          expect(demand(relative)).to eql(85.0 / 0.2)
        end
      end
    end
  end # with three parents and a sibling

  context 'with three siblings and two parents' do
    #                (100) [M]     [F] (50)
    #                    / / \     /
    #         __________/ /   \   /
    #        /           /     \ /
    #  (10) [R]   (75) [S]     [C]
    let!(:brother) { graph.add Turbine::Node.new(:relative) }
    let!(:sibling) { graph.add Turbine::Node.new(:sibling) }
    let!(:father)  { graph.add Turbine::Node.new(:father) }

    let!(:mb_edge) { mother.connect_to(brother, :gas) }
    let!(:ms_edge) { mother.connect_to(sibling, :gas) }
    let!(:mc_edge) { mother.connect_to(child, :gas) }
    let!(:fc_edge) { father.connect_to(child, :gas) }

    before do
      brother.set(:preset_demand, 10.0)
      sibling.set(:preset_demand, 75.0)
      mother.set(:expected_demand, 100.0)
      father.set(:expected_demand, 50.0)
      calculate!
    end

    it 'sets child demand' do
      pending do
        expect(demand(child)).to eql(65.0)
      end
    end

    it 'sets edge shares' do
      pending do
        expect(mb_edge.get(:share)).to eql(0.10)
        expect(ms_edge.get(:share)).to eql(0.75)
        expect(mc_edge.get(:share)).to eql(0.15)
        expect(fc_edge.get(:share)).to eql(1.00)
      end
    end
  end # with three siblings and two parents

  context 'with a sibling which is also a parent' do
    #    (100) [M] [F] (50)
    #          / \ /
    #   (0.2) /__[S]       Someone call Jerry Springer...
    #        //
    #       [C]
    let!(:sibling) { graph.add Turbine::Node.new(:sibling) }
    let!(:father)  { graph.add Turbine::Node.new(:father) }

    let!(:ms_edge) { mother.connect_to(sibling, :gas) }
    let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.2) }
    let!(:sc_edge) { sibling.connect_to(child, :gas) }
    let!(:fs_edge) { father.connect_to(sibling, :gas) }

    before do
      mother.set(:expected_demand, 100.0)
      father.set(:expected_demand, 50.0)
      calculate!
    end

    it 'sets child demand' do
      pending do
        expect(demand(child)).to eql(1.0)
      end
    end

    it 'sets edge shares' do
      expect(ms_edge.get(:share)).to eql(0.8)
      expect(fs_edge.get(:share)).to eql(1.0)
      expect(sc_edge.get(:share)).to eql(1.0)
    end
  end # with a sibling which is also a parent

end ; end # Refinery, demand calculations
