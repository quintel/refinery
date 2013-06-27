require 'spec_helper'

describe Refinery::PreciseProperties do
  let(:model) do
    Class.new do
      include Turbine::Properties
      include Refinery::PreciseProperties

      precise_property :share
    end.new
  end

  context 'when mass-assigning properties' do
    context 'on "precise_property" properties' do
      it 'casts Integers to Rational' do
        model.properties = { share: 1 }
        expect(model.get(:share)).to eq(Rational('1'))
      end

      it 'casts Floats to Rational' do
        model.properties = { share: 1.0 }
        expect(model.get(:share)).to eq(Rational('1'))
      end

      it 'casts Strings to Rational' do
        model.properties = { share: '1/5' }
        expect(model.get(:share)).to eq(Rational('1/5'))
      end

      it 'does not cast nil' do
        expect { model.properties = { share: nil } }.to_not raise_error
        expect(model.get(:share)).to be_nil
      end
    end

    context 'on non-"precise_property" properties' do
      it 'does not cast Integers to Rational' do
        model.properties = { lifetime: 1 }

        expect(model.get(:lifetime)).to eq(1)
        expect(model.get(:lifetime)).to be_kind_of(Integer)
      end

      it 'does not cast Floats to Rational' do
        model.properties = { lifetime: 1.0 }

        expect(model.get(:lifetime)).to eq(1.0)
        expect(model.get(:lifetime)).to be_kind_of(Float)
      end
    end

    context 'given nil' do
      it 'should set nothing' do
        expect { model.properties = nil }.to_not raise_error
        expect(model.properties).to be_empty
      end
    end
  end

  context 'setting properties individually' do
    context 'on "precise_property" properties' do
      it 'casts Integers to Rational' do
        model.set(:share, 1)
        expect(model.get(:share)).to eq(Rational('1'))
      end

      it 'casts Floats to Rational' do
        model.set(:share, 1.0)
        expect(model.get(:share)).to eq(Rational('1'))
      end

      it 'sets negative values to zero' do
        model.set(:share, -0.1)
        expect(model.get(:share)).to eq(0)
      end

      it 'does not cast nil' do
        model.set(:share, nil)
        expect(model.get(:share)).to be_nil
      end
    end

    context 'on non-"precise_property" properties' do
      it 'does not cast Integers to Rational' do
        model.set(:lifetime, 1)

        expect(model.get(:lifetime)).to eq(1)
        expect(model.get(:lifetime)).to be_kind_of(Integer)
      end

      it 'does not cast Floats to Rational' do
        model.set(:lifetime, 1.0)

        expect(model.get(:lifetime)).to eq(1.0)
        expect(model.get(:lifetime)).to be_kind_of(Float)
      end
    end
  end

  context 'using on a non Turbine::Properties class' do
    it 'raises an error' do
      expect do
        Class.new { include Refinery::PreciseProperties }
      end.to raise_error
    end
  end
end # Refinery::PreciseProperties
