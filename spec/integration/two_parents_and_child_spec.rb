require 'spec_helper'

describe 'Graph calculations; with two parents' do
  let!(:mother) { graph.add Refinery::Node.new(:mother) }
  let!(:father) { graph.add Refinery::Node.new(:father) }
  let!(:child)  { graph.add Refinery::Node.new(:child) }

  context 'the parents have demand' do
    #   (30) [M] [F] (20)
    #          \ /
    #          [C]
    before do
      mother.set(:demand, 30.0)
      father.set(:demand, 20.0)
    end

    context 'and the edges both have demands' do
      let!(:mc_edge) { mother.connect_to(child, :gas, demand: 30.0) }
      let!(:fc_edge) { father.connect_to(child, :gas, demand: 20.0) }

      before { calculate! }

      it 'sets demand' do
        expect(child).to have_demand.of(50.0)
      end

      it { expect(graph).to validate }
    end

    context 'and neither edge has a demand' do
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(child).to have_demand.of(50.0)
      end

      it 'sets the edge demands' do
        expect(mc_edge).to have_demand.of(30.0)
        expect(fc_edge).to have_demand.of(20.0)
      end

      it { expect(graph).to validate }
    end

    context 'and demand is missing on one' do
      #   (30) [M] [F]
      #          \ /
      #          [C]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before do
        father.set(:demand, nil)
        calculate!
      end

      it 'does not set demand' do
        expect(child).to_not have_demand
      end

      it 'sets the M->C demand' do
        expect(mc_edge).to have_demand.of(30.0)
      end

      it 'does not set the F->C demand' do
        expect(fc_edge).to_not have_demand
      end

      it { expect(graph).to_not validate }
    end
  end # the parents have demand

  context 'one parent has demand' do
    let!(:mc_edge) { mother.connect_to(child, :gas, demand: 60.0) }
    let!(:fc_edge) { father.connect_to(child, :gas) }

    context "but the child doesn't" do
      #   (60) [M] [F]
      #    (60)  \ / (240)
      #          [C]
      before do
        mother.set(:demand, 60.0)
        fc_edge.set(:demand, 240.0)
        calculate!
      end

      it "does sets the other parent's demand" do
        expect(father).to have_demand.of(240.0)
      end

      it "does sets the child's demand" do
        expect(child).to have_demand.of(300.0)
      end

      it { expect(graph).to validate }
    end

    context 'as does the child' do
      #   (60) [M] [F]
      #          \ /
      #          [C] (240)
      before do
        mother.set(:demand, 60)
        child.set(:demand, 240.0)

        mc_edge.set(:demand, nil)

        calculate!
      end

      it 'sets M->C demand'  do
        expect(mc_edge).to have_demand.of(60.0)
      end

      it 'sets F->C demand' do
        expect(fc_edge).to have_demand.of(180.0)
      end

      it "sets the other parent's demand" do
        expect(father).to have_demand.of(180.0)
      end

      it { expect(graph).to validate }
    end
  end # one parent has demand

  context 'the child has demand' do
    let!(:mc_edge) { mother.connect_to(child, :gas) }
    let!(:fc_edge) { father.connect_to(child, :gas) }

    before { child.set(:demand, 100.0) }

    context 'and the links have child shares' do
      #       [M]  [F]
      #   (75%) \ / (25%)
      #         [C] (100)
      before do
        mc_edge.set(:child_share, 0.75)
        fc_edge.set(:child_share, 0.25)

        calculate!
      end

      it "sets the first parent's demand" do
        expect(mother).to have_demand.of(75.0)
      end

      it "sets the second parent's demand" do
        expect(father).to have_demand.of(25.0)
      end

      it { expect(graph).to validate }
    end

    context 'and one link has a child share' do
      #       [M]  [F]
      #   (75%) \ /
      #         [C] (100)
      before do
        child.set(:demand, 100.0)
        mc_edge.set(:child_share, 0.75)

        calculate!
      end

      it "sets the first parent's demand" do
        expect(mother).to have_demand.of(75.0)
      end

      it "sets the second parent's demand" do
        expect(father).to have_demand.of(25.0)
      end

      it 'sets M->C demand' do
        expect(mc_edge).to have_demand.of(75.0)
      end

      it 'sets F->C demand' do
        expect(fc_edge).to have_demand.of(25.0)
      end

      it { expect(graph).to validate }
    end
  end # the child has demand

  context 'and the edges use different carriers' do
    let!(:mc_edge) { mother.connect_to(child, :gas) }
    let!(:fc_edge) { father.connect_to(child, :electricity) }

    context 'and the parents define demand' do
      #   (30) [M] [F] (20)
      #          \ /
      #          [C]
      before do
        mother.set(:demand, 30)
        father.set(:demand, 20)

        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_edge).to have_child_share.of(1)
        expect(fc_edge).to have_child_share.of(1)
      end

      it 'sets the edge demands' do
        expect(mc_edge).to have_demand.of(30)
        expect(fc_edge).to have_demand.of(20)
      end

      it 'calculates the child slot shares' do
        expect(child.slots.in(:gas).share).to eq(30.0 / 50)
        expect(child.slots.in(:electricity).share).to eq(20.0 / 50)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(50)
      end

      it { expect(graph).to validate }
    end # and the parents define demand

    context 'and the child defines output shares' do
      before do
        #   (30) [M] [F]
        #    (0.6) \ / (0.4)
        #          [C]
        mother.set(:demand, 30)
        child.slots.in(:gas).set(:share, 0.6)
        child.slots.in(:electricity).set(:share, 0.4)

        calculate!
      end

      it 'sets the edge shares' do
        expect(mc_edge).to have_child_share.of(1)
        expect(fc_edge).to have_child_share.of(1)
      end

      it 'sets the edge demands' do
        expect(mc_edge).to have_demand.of(30)
        expect(fc_edge).to have_demand.of(20)
      end

      it 'calculates the child slot shares' do
        expect(child.slots.in(:gas).share).to eq(30.0 / 50)
        expect(child.slots.in(:electricity).share).to eq(20.0 / 50)
      end

      it 'sets child demand' do
        expect(child).to have_demand.of(50)
      end

      it { expect(graph).to validate }
    end # and the child defines output shares

    context 'and the child defines only one output share' do
      before do
        #   (30) [M] [F]
        #    (0.6) \ /
        #          [C]
        mother.set(:demand, 30)
        child.slots.in(:gas).set(:share, 0.6)

        calculate!
      end

      it 'sets edge shares' do
        expect(mc_edge).to have_child_share.of(1)
        expect(fc_edge).to have_child_share.of(1)
      end

      it 'calculates child slot shares when a parent share is present' do
        expect(child.slots.in(:gas).share).to eq(30.0 / 50.0)
      end

      it 'does not calculate share-less child slot shares' do
        expect(child.slots.in(:electricity).share).to be_nil
      end

      it 'does sets child demand' do
        expect(child).to have_demand.of(50)
      end

      it { expect(graph).to_not validate }
    end # and the child defines only one output share
  end # and the edges use different carriers
end # Graph calcualtions; with two parents
