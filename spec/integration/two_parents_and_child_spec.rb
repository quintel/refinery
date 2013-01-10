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
      mother.set(:expected_demand, 30.0)
      father.set(:expected_demand, 20.0)
    end

    context 'and the edges both have shares' do
      let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.6) }
      let!(:fc_edge) { father.connect_to(child, :gas, share: 0.4) }

      before { calculate! }

      it 'sets demand' do
        expect(child.demand).to eql(50.0)
      end
    end

    context 'and neither edge has a share' do
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before { calculate! }

      it 'sets demand' do
        expect(child.demand).to eql(50.0)
      end

      it 'sets the edge shares' do
        expect(mc_edge.get(:share)).to eql(30.0 / 50)
        expect(fc_edge.get(:share)).to eql(20.0 / 50)
      end
    end

    context 'and demand is missing on one' do
      #   (30) [M] [F]
      #          \ /
      #          [C]
      let!(:mc_edge) { mother.connect_to(child, :gas) }
      let!(:fc_edge) { father.connect_to(child, :gas) }

      before do
        father.set(:expected_demand, nil)
        calculate!
      end

      it 'does not set demand' do
        expect(child.demand).to be_nil
      end

      it 'does not set the M->C share' do
        expect(mc_edge.get(:share)).to be_nil
      end

      it 'does not set the F->C share' do
        expect(fc_edge.get(:share)).to be_nil
      end
    end
  end # the parents have demand

  context 'one parent has demand' do
    let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.2) }
    let!(:fc_edge) { father.connect_to(child, :gas, share: 0.8) }

    context "but the child doesn't" do
      #   (60) [M] [F]
      #   (0.2)  \ / (0.8)
      #          [C]
      before do
        mother.set(:expected_demand, 60.0)
        calculate!
      end

      it "does sets the other parent's demand" do
        expect(father.demand).to eql(240.0)
      end

      it "does sets the child's demand" do
        expect(child.demand).to eql(300.0)
      end
    end

    context 'as does the child' do
      #   (60) [M] [F]
      #   (0.25) \ /
      #          [C] (240)
      before do
        child.set(:preset_demand, 240.0)
        mc_edge.set(:share, 0.25)
        fc_edge.set(:share, nil)
        calculate!
      end

      it 'sets F->C share' do
        expect(fc_edge.get(:share)).to eql(0.75)
      end

      it "sets the other parent's demand" do
        expect(father.demand).to eql(180.0)
      end
    end
  end # one parent has demand

  context 'the child has demand' do
    #       [M]  [F]
    #  (0.75) \ / (0.25)
    #         [C] (100)
    let!(:mc_edge) { mother.connect_to(child, :gas, share: 0.75) }
    let!(:fc_edge) { father.connect_to(child, :gas, share: 0.25) }

    before do
      child.set(:preset_demand, 100.0)
      calculate!
    end

    it "sets the first parent's demand" do
      expect(mother.demand).to eql(75.0)
    end

    it "sets the second parent's demand" do
      expect(father.demand).to eql(25.0)
    end
  end # the child has demand
end # Graph calcualtions; with two parents
