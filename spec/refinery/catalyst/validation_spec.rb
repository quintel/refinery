require 'spec_helper'

module Refinery
  describe Catalyst::Validation do
    let!(:graph)     { Turbine::Graph.new }
    let(:validation) { Catalyst::Validation.new(graph).run! }

    context 'given an oversupply' do
      #   (50) [A] [B] (50)
      #     (50) \ / (0)
      #          [X] (50)
      let!(:a)       { graph.add(Node.new(:a, expected_demand: 50.0)) }
      let!(:b)       { graph.add(Node.new(:b, expected_demand: 50.0)) }
      let!(:x)       { graph.add(Node.new(:x, preset_demand:   50.0)) }
      let!(:ax_edge) { a.connect_to(x, :gas, demand: 50.0) }
      let!(:bx_edge) { b.connect_to(x, :gas, demand: 0.0) }

      it 'has one invalid object' do
        expect(validation.errors).to have(1).element
      end

      it 'asserts that [A] has valid output' do
        expect(validation.errors[a.slots.out(:gas)]).to be_nil
      end

      it 'asserts that [B] has invalid output' do
        expect(validation.errors[b.slots.out(:gas)]).to have(1).error
      end

      it 'asserts that [X] has valid input' do
        expect(validation.errors[x.slots.in(:gas)]).to be_nil
      end
    end # given an oversupply

    context 'given an undersupply' do
      #   [A] (10)
      #    |  (10)
      #   [X] (20)
      let!(:a)       { graph.add(Node.new(:a, expected_demand: 10.0)) }
      let!(:x)       { graph.add(Node.new(:x, preset_demand:   20.0)) }
      let!(:ax_edge) { a.connect_to(x, :gas, demand: 10.0) }

      it 'has one invalid object' do
        expect(validation.errors).to have(1).element
      end

      it 'asserts that [A] has valid output' do
        expect(validation.errors[a.slots.out(:gas)]).to be_nil
      end

      it 'asserts that [B] has invalid input' do
        expect(validation.errors[x.slots.in(:gas)]).to have(1).error
      end
    end

    context 'given a slot with no edges' do
      #   [A] (20)
      #    |  (20)
      #   [X] (20)
      let!(:a)       { graph.add(Node.new(:a, expected_demand: 20.0)) }
      let!(:x)       { graph.add(Node.new(:x, preset_demand:   20.0)) }
      let!(:ax_edge) { a.connect_to(x, :gas, demand: 20.0) }

      before do
        a.slots.in.add(:electricity, share: 1.0)
      end

      it 'has no invalid objects' do
        expect(validation.errors).to have(:no).elements
      end

      it 'ignores the empty input slot' do
        expect(validation.errors[a.slots.in(:electricity)]).to be_nil
      end

      it 'asserts that [A] has valid output' do
        expect(validation.errors[a.slots.out(:gas)]).to be_nil
      end

      it 'asserts that [X] has valid input' do
        expect(validation.errors[x.slots.in(:gas)]).to be_nil
      end
    end # given a slot with no edges

    context 'given an edge without demand' do
      #   [A] (50)
      #    |
      #   [X] (50)
      let!(:a)       { graph.add(Node.new(:a, expected_demand: 20.0)) }
      let!(:x)       { graph.add(Node.new(:x, preset_demand:   20.0)) }
      let!(:ax_edge) { a.connect_to(x, :gas) }

      it 'has one invalid object' do
        expect(validation.errors).to have(1).element
      end

      it 'asserts that A->X is invalid' do
        expect(validation.errors[ax_edge]).to have(1).error
      end

      it 'does not test the output of [A]' do
        expect(validation.errors[a.slots.out(:gas)]).to be_nil
      end

      it 'does not test the input of [X]' do
        expect(validation.errors[x.slots.in(:gas)]).to be_nil
      end
    end # given an edge without demand

    context 'given a node without demand' do
      #   [A]
      #    |  (50)
      #   [X] (50)
      let!(:a)       { graph.add(Node.new(:a)) }
      let!(:x)       { graph.add(Node.new(:x, preset_demand: 50.0)) }
      let!(:ax_edge) { a.connect_to(x, :gas, demand: 50.0) }

      it 'has one invalid object' do
        expect(validation.errors).to have(1).element
      end

      it 'asserts that [A] is invalid' do
        expect(validation.errors[a]).to have(1).error
      end

      it 'does not add an error for the invalid [A] output' do
        expect(validation.errors[a.slots.out(:gas)]).to be_nil
      end

      it 'asserts that [X] has valid input' do
        expect(validation.errors[x.slots.in(:gas)]).to be_nil
      end
    end # given a node without demand
  end # Catalyst::Validation
end # Refinery
