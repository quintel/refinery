require 'spec_helper'

describe 'Graph calculations; three parents' do
  [ :a, :b, :c, :x ].each do |key|
    let(key) { graph.add Refinery::Node.new(key) }
  end

  let!(:ax_edge) { a.connect_to(x, :gas) }
  let!(:bx_edge) { b.connect_to(x, :gas) }
  let!(:cx_edge) { c.connect_to(x, :gas) }

  describe 'when the child has no demand' do
    context 'but all parents do' do
      #  (10) [A]     [B] (75)   [C] (15)
      #         \     /          /
      #          \   / _________/
      #           \ / /
      #           [X]
      before do
        a.set(:expected_demand, 10.0)
        b.set(:expected_demand, 75.0)
        c.set(:expected_demand, 15.0)

        calculate!
      end

      it 'sets demand of the child' do
        expect(x).to have_demand.of(100.0)
      end

      it 'sets A->X share' do
        expect(ax_edge).to have_share.of(0.1)
      end

      it 'sets B->X share' do
        expect(bx_edge).to have_share.of(0.75)
      end

      it 'sets C->X share' do
        expect(cx_edge).to have_share.of(0.15)
      end

      it { expect(graph).to validate }
    end # but all parents do

    context 'and neither does one parent' do
      #  (10) [A]     [B] (75)   [C]
      #         \     /          /
      #          \   / _________/
      #           \ / /
      #           [X]
      before do
        a.set(:expected_demand, 10.0)
        b.set(:expected_demand, 75.0)

        calculate!
      end

      context 'and there are no edge demands' do
        it 'does not set demand of the child' do
          expect(x).to_not have_demand
        end

        it 'does not set demand of missing parent' do
          expect(c).to_not have_demand
        end

        it 'sets A->X demand' do
          expect(ax_edge).to have_demand.of(10.0)
        end

        it 'sets B->X demand' do
          expect(bx_edge).to have_demand.of(75.0)
        end

        it 'does not set C->X demand' do
          expect(cx_edge).to_not have_demand
        end

        it { expect(graph).to_not validate }
      end

      context 'and there are edge shares' do
        before do
          ax_edge.set(:share, 0.10)
          bx_edge.set(:share, 0.75)
          cx_edge.set(:share, 0.15)

          calculate!
        end

        it 'sets demand of the child' do
          expect(x).to have_demand.of(100.0)
        end

        it 'sets C->X demand' do
          expect(cx_edge).to have_demand.of(15.0)
        end

        it 'sets demand of the missing parent' do
          expect(c).to have_demand.of(15.0)
        end

        it { expect(graph).to validate }
      end
    end # and neither does one parent
  end # when the child has no demand

  describe 'when the child has demand' do
    #  [A]     [B]        [C]
    #    \     /          /
    #     \   / _________/
    #      \ / /
    #      [X] (200)
    before { x.set(:preset_demand, 200.0) }

    describe 'and edges have shares' do
      before do
        ax_edge.set(:share, 0.10)
        bx_edge.set(:share, 0.75)
        cx_edge.set(:share, 0.15)

        calculate!
      end

      it 'sets demand of the first parent' do
        expect(a).to have_demand.of(20.0)
      end

      it 'sets demand of the second parent' do
        expect(b).to have_demand.of(150.0)
      end

      it 'sets demand of the third parent' do
        expect(c).to have_demand.of(30.0)
      end

      it { expect(graph).to validate }
    end

    describe 'and no edges have shares' do
      before { calculate! }

      it 'does not set edge shares' do
        expect(ax_edge).to_not have_share
        expect(bx_edge).to_not have_share
        expect(cx_edge).to_not have_share
      end

      it 'does not set parent demands' do
        expect(a).to_not have_demand
        expect(b).to_not have_demand
        expect(c).to_not have_demand
      end

      it { expect(graph).to_not validate }
    end
  end # when the child has demand
end # Graph calculations; three parents
