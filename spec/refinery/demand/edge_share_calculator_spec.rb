require 'spec_helper'

module Refinery::Demand ; describe 'Share calculations' do
  let(:parent)  { Turbine::Node.new(:parent) }
  let(:child)   { Turbine::Node.new(:child) }
  let(:sibling) { Turbine::Node.new(:sibling) }

  let(:edge)    { parent.connect_to(child, :gas) }
  let(:x)       { EdgeShareCalculator.new(edge) }

  before do
    parent.set(:calculator,  NodeDemandCalculator.new(parent))
    child.set(:calculator,   NodeDemandCalculator.new(child))
    sibling.set(:calculator, NodeDemandCalculator.new(sibling))
  end

  # --------------------------------------------------------------------------

  context 'when the "from" node has no other out edges' do
    #          P
    #          | (nil)
    #          C
    it 'is calculable' do
      expect(x).to be_calculable
    end

    it 'sets the share to 1.0' do
      x.calculate!
      expect(edge.get(:share)).to eql(1.0)
    end

    context 'and child demand exceeds parent supply' do
      before do
        parent.set(:expected_demand, 1.0)
        child.set(:preset_demand, 2.0)
      end

      it 'sets the share to 1.0' do
        x.calculate!
        expect(edge.get(:share)).to eql(1.0)
      end
    end
  end

  context 'when the "from" node has two shareless out edges' do
    #          P
    # (nil) x / \ (nil)
    #        C   S
    before do
      # A link to itself suffices.
      parent.connect_to(parent, :gas)
    end

    it 'is not calculable' do
      expect(x).to_not be_calculable
    end
  end

  context 'when the "from" node has a second edge with a share' do
    #          P
    #       x / \ (0.6)
    #        C   S
    before do
      # A link to itself suffices.
      parent.connect_to(parent, :gas, share: 0.6)
    end

    it 'is calculable' do
      expect(x).to be_calculable
    end

    it 'sets the share to 1.0' do
      x.calculate!
      expect(edge.get(:share)).to eql(0.4)
    end
  end

  context 'when the "from" node has two shareless out edges in different carriers' do
    #          P
    #   x:gas | | o:electricity
    #          C
    before do
      pending 'Awaiting carrier support'
      parent.connect_to(child, :electricity)
    end

    it 'is calculable' do
      expect(x).to be_calculable
    end

    it 'sets share to 1.0' do
      expect(edge.get(:share)).to eql(1.0)
    end
  end

  context 'when the "to" node has sibling with a different carrier' do
    #          P
    #   x:gas / \ o:electricity
    #        C   S
    before do
      pending 'Awaiting carrier support'
      parent.connect_to(child, :electricity)
    end

    it 'is calculable' do
      expect(x).to be_calculable
    end

    it 'sets share to 1.0' do
      expect(edge.get(:share)).to eql(1.0)
    end
  end

  describe 'inferring from the "to" node' do
    context 'with a single child node' do
      #          P
      #          | x
      #   (50.0) C
      before do
        child.set(:preset_demand, 50.0)
      end

      it 'is calculable' do
        expect(x).to be_calculable
      end

      it 'sets the share' do
        x.calculate!
        expect(edge.get(:share)).to eql(1.0)
      end
    end # with a single child node

    context 'with multiple child nodes' do
      before do
        parent.connect_to(sibling, :gas)
      end

      context 'and both have demand' do
        #          P
        #       x / \
        # (25.0) C   S (15.0)
        before do
          child.set(:preset_demand, 25.0)
          sibling.set(:preset_demand, 15.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets the share' do
          x.calculate!
          expect(edge.get(:share)).to eql(0.625)
        end
      end

      context 'and "to" has no demand' do
        #          P
        #       x / \
        #  (nil) C   S (50.0)
        before do
          sibling.set(:preset_demand, 50.0)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end

      context 'and the sibling has no demand' do
        #          P
        #       x / \
        # (25.0) C   S (nil)
        before do
          child.set(:preset_demand, 25.0)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end
    end # with multiple child nodes
  end # inferring from the "to" node

  describe 'inferring from the "from" node(s)' do
    before { pending 'Not done yet' }

    describe 'when the child has multiple parents and a sibling' do
      let!(:parent_two)      { Turbine::Node.new(:parent_two) }
      let!(:sibling_edge)    { parent.connect_to(sibling, :gas) }
      let!(:parent_two_edge) { parent_two.connect_to(child, :gas) }

      context 'and all nodes have demand' do
        #   (100.0) P      P2 (100.0)
        #          / \ x   /
        #  (75.0) S   \   /
        #              \ /
        #               C (125.0)
        before do
          sibling.set(:preset_demand, 75.0)
          parent.set(:expected_demand, 100.0)
          child.set(:preset_demand, 75.0)
          parent_two.set(:expected_demand, 100.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          x.calculate!
          expect(edge.get(:share)).to eql(0.25)
        end
      end

      context 'and the sibling has no demand' do
        #   (100.0) P      P2 (100.0)
        #          / \ x   /
        #   (nil) S   \   /
        #              \ /
        #               C (125.0)
        before do
          parent.set(:expected_demand, 100.0)
          child.set(:preset_demand, 125.0)
          parent_two.set(:expected_demand, 100.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          x.calculate!
          expect(edge.get(:share)).to eql(0.25)
        end
      end

      context 'and the sibling and parent have no demand' do
        #     (nil) P      P2 (100.0)
        #          / \ x   /
        #   (nil) S   \   /
        #              \ /
        #               C (125.0)
        before do
          child.set(:preset_demand, 125.0)
          parent_two.set(:expected_demand, 100.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          expect(edge.get(:share)).to eql(0.25)
        end
      end

      context 'and the second parent has no demand' do
        #   (100.0) P      P2 (nil)
        #          / \ x   /
        #  (75.0) S   \   /
        #              \ /
        #               C (125.0)
        before do
          sibling.set(:preset_demand, 75.0)
          parent.set(:expected_demand, 100.0)
          child.set(:preset_demand, 125.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          x.calculate!
          expect(edge.get(:share)).to eql(0.25)
        end
      end

      context 'and the second parent is a partial supplier' do
        #   (100.0) P       P2 (100.0)
        #          / \ x   /
        #   (nil) S   \   / (0.5)
        #              \ /
        #       (125.0) C
        before do
          parent.set(:expected_demand, 100.0)
          child.set(:preset_demand, 125.0)
          parent_two_edge.set(:share, 0.5)
          parent_two.set(:expected_demand, 100.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          x.calculate!
          expect(edge.get(:share)).to eql(0.75)
        end
      end

      context 'and the child and second parent have no demand' do
        #   (100.0) P      P2 (nil)
        #          / \ x   /
        #  (75.0) S   \   /
        #              \ /
        #               C (nil)
        before do
          sibling.set(:preset_demand, 75.0)
          parent.set(:expected_demand, 100.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets share, accounting for energy supplied by the other parent' do
          x.calculate!
          expect(edge.get(:share)).to eql (0.25)
        end
      end

      context 'and the child and sibling have no demand' do
        #   (100.0) P      P2 (100.0)
        #          / \ x   /
        #   (nil) S   \   /
        #              \ /
        #               C (nil)
        before do
          parent.set(:expected_demand, 100.0)
          parent_two.set(:expected_demand, 100.0)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end
    end # when the child has multiple parents
  end # inferring from the "from" node(s)
end ; end # Refinery::Demand
