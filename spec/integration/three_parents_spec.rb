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
        expect(x.demand).to eql(100.0)
      end

      it 'sets A->X share' do
        expect(ax_edge.get(:share)).to eql(0.1)
      end

      it 'sets B->X share' do
        expect(bx_edge.get(:share)).to eql(0.75)
      end

      it 'sets C->X share' do
        expect(cx_edge.get(:share)).to be_within(1e-9).of(0.15) # FP precision
      end
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

      context 'and there are no edge shares' do
        it 'does not set demand of the child' do
          expect(x.demand).to be_nil
        end

        it 'does not set demand of missing parent' do
          expect(c.demand).to be_nil
        end

        it 'does not set edge shares' do
          expect(ax_edge.get(:share)).to be_nil
          expect(bx_edge.get(:share)).to be_nil
          expect(cx_edge.get(:share)).to be_nil
        end
      end

      context 'and there are edge shares' do
        before do
          ax_edge.set(:share, 0.10)
          bx_edge.set(:share, 0.75)
          cx_edge.set(:share, 0.15)

          calculate!
        end

        it 'sets demand of the child' do
          expect(x.demand).to eql(100.0)
        end

        it 'sets demand of the missing parent' do
          expect(c.demand).to eql(15.0)
        end
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
        expect(a.demand).to eql(20.0)
      end

      it 'sets demand of the second parent' do
        expect(b.demand).to eql(150.0)
      end

      it 'sets demand of the third parent' do
        expect(c.demand).to eql(30.0)
      end
    end

    describe 'and no edges have shares' do
      before { calculate! }

      it 'does not set edge shares' do
        expect(ax_edge.get(:share)).to be_nil
        expect(bx_edge.get(:share)).to be_nil
        expect(cx_edge.get(:share)).to be_nil
      end

      it 'does not set parent demands' do
        expect(a.demand).to be_nil
        expect(b.demand).to be_nil
        expect(c.demand).to be_nil
      end
    end
  end # when the child has demand
end # Graph calculations; three parents
