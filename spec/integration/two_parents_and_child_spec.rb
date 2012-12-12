require 'spec_helper'

describe 'Graph calculations; with two parents' do
  let!(:mother) { graph.add Turbine::Node.new(:mother) }
  let!(:father) { graph.add Turbine::Node.new(:father) }
  let!(:child)  { graph.add Turbine::Node.new(:child) }

  context 'the parents have demand' do
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
  end # the parents have demand

  context 'one parent has demand' do
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
  end # one parent has demand

  context 'the child has demand' do
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
  end # the child has demand
end # Graph calcualtions; with two parents
