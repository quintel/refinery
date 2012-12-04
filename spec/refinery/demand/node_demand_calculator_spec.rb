require 'spec_helper'

module Refinery::Demand ; describe 'Demand calculations:' do
  let(:x_node) { Turbine::Node.new(:x) }
  let(:a_node) { Turbine::Node.new(:a) }
  let(:b_node) { Turbine::Node.new(:b) }

  let(:x) { NodeDemandCalculator.new(x_node) }
  let(:a) { NodeDemandCalculator.new(a_node) }
  let(:b) { NodeDemandCalculator.new(b_node) }

  before do
    x_node.set(:calculator, x)
    a_node.set(:calculator, a)
    b_node.set(:calculator, b)
  end

  # --------------------------------------------------------------------------

  context 'calculating from parents' do
    context 'with a single parent; demand set' do
      #     (45) A
      #          |
      #          X
      before do
        a_node.set(:expected_demand, 45.0)
      end

      context 'and the edge has a share' do
        before do
          a_node.connect_to(x_node, :gas, share: 1.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets demand' do
          x.calculate!
          expect(x.demand).to eql(45.0)
        end
      end # and the edge has a share

      context 'and the edge has no share' do
        before do
          a_node.connect_to(x_node, :gas)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end # and the edge has no share
    end # with a single parent; demand set

    context 'with two parents; demand set' do
      #   (45) A   B (25)
      #         \ /
      #          X
      before do
        a_node.set(:expected_demand, 45.0)
        b_node.set(:expected_demand, 25.0)
      end

      context 'and the edges both have shares' do
        before do
          a_node.connect_to(x_node, :gas, share: 1.0)
          b_node.connect_to(x_node, :gas, share: 1.0)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets demand' do
          x.calculate!
          expect(x.demand).to eql(70.0)
        end
      end # and the edges both have shares

      context 'and one edge has no share' do
        before do
          a_node.connect_to(x_node, :gas, share: 1.0)
          b_node.connect_to(x_node, :gas)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end # and one edge has no share
    end # with two parents; demand set

    context 'with two parents; demand missing on one' do
      #   (45) A   B (nil)
      #         \ /
      #          X
      before do
        a_node.connect_to(x_node, :gas, share: 1.0)
        b_node.connect_to(x_node, :gas, share: 1.0)
        a_node.set(:expected_demand, 45.0)
      end

      it 'is not calculable' do
        expect(x).to_not be_calculable
      end
    end # with two parents; demand missing on one

    context 'with one parent which also supplies a sibling' do
      #          A (50)
      #   (0.6) / \ (0.4)
      #        B   X
      before do
        a_node.set(:expected_demand, 50.0)
        a_node.connect_to(b_node, :gas, share: 0.6)
        a_node.connect_to(x_node, :gas, share: 0.4)
      end

      it 'is calculable' do
        expect(x).to be_calculable
      end

      it 'sets demand' do
        x.calculate!
        expect(x.demand).to eql(20.0)
      end
    end # with one parent which also supplies a sibling
  end # calculating from parents

  context 'calculating from children' do
    context 'with a single child; demand set' do
      #          X
      #          |
      #     (45) A
      before do
        a_node.set(:preset_demand, 45.0)
      end

      context 'and the edge has a share' do
        before do
          x_node.connect_to(a_node, :gas, share: 1.0)
        end

        it 'is not calculable' do
          expect(x).to be_calculable
        end

        it 'sets demand' do
          x.calculate!
          expect(x.demand).to eql(45.0)
        end
      end # and the edge has a share

      context 'and the edge has no share' do
        before do
          x_node.connect_to(a_node, :gas)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end # and the edge has no share
    end # with a single child; demand set

    context 'with a single child; demand missing' do
      before do
        x_node.connect_to(a_node, :gas, share: 1.0)
      end

      #          X
      #          |
      #    (nil) A
      it 'is not calculable' do
        expect(x).to_not be_calculable
      end
    end # with a single child; demand missing

    context 'with two children; demand set' do
      #          X
      #         / \
      #   (30) A   B (20)
      before do
        a_node.set(:preset_demand, 30.0)
        b_node.set(:preset_demand, 20.0)
      end

      context 'when both edges have a share' do
        before do
          x_node.connect_to(a_node, :gas, share: 0.6)
          x_node.connect_to(b_node, :gas, share: 0.4)
        end

        it 'is calculable' do
          expect(x).to be_calculable
        end

        it 'sets demand' do
          x.calculate!
          expect(x.demand).to eql(50.0)
        end
      end # when both edges have a share

      context 'when one edge is missing a share' do
        before do
          x_node.connect_to(a_node, :gas, share: 0.6)
          x_node.connect_to(b_node, :gas)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end # when one edge is missing a share
    end # with two children; demand set

    context 'with two children; demand missing on one' do
      before do
        x_node.connect_to(a_node, :gas, share: 0.3)
        x_node.connect_to(b_node, :gas)
        a_node.set(:preset_demand, 100.0)
      end

      #          X
      #         / \
      #  (100) A   B (nil)
      it 'is not calculable' do
        expect(x).to_not be_calculable
      end
    end # with two children; demand missing on one

    context 'when the child receives demand from multiple ancestors' do
      #        X   B
      #  (0.75) \ / (0.25)
      #          A (100)
      before do
        x_node.connect_to(a_node, :gas, share: 0.75)
        b_node.connect_to(a_node, :gas, share: 0.25)
        a_node.set(:preset_demand, 100.0)
      end

      it 'is calculable' do
        expect(x).to be_calculable
      end

      it 'sets demand' do
        x.calculate!
        expect(x.demand).to eql(75.0)
      end

      context 'and an ancestor edge has no share' do
        #        X   B
        #  (0.75) \ / (nil)
        #          A (100)
        before do
          b_node.out_edges.first.set(:share, nil)
        end

        it 'is not calculable' do
          expect(x).to_not be_calculable
        end
      end # and an ancestor edge has no share
    end # when the child receives demand from multiple ancestors
  end # calculating from children
end ; end # Refinery::Demand
