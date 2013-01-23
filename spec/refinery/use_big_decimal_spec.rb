require 'spec_helper'

describe Refinery::UseBigDecimal do
  let(:model) do
    Class.new do
      include Turbine::Properties
      include Refinery::UseBigDecimal

      use_big_decimal :share
    end.new
  end

  context 'when mass-assigning properties' do
    context 'on "use_big_decimal" properties' do
      it 'casts Integers to BigDecimal' do
        model.properties = { share: 1 }
        expect(model.get(:share)).to eql(BigDecimal.new('1.0'))
      end

      it 'casts Floats to BigDecimal' do
        model.properties = { share: 1.0 }
        expect(model.get(:share)).to eql(BigDecimal.new('1.0'))
      end

      it 'does not cast nil' do
        expect { model.properties = { share: nil } }.to_not raise_error
        expect(model.get(:share)).to be_nil
      end
    end

    context 'on non-"use_big_decimal" properties' do
      it 'does not cast Integers to BigDecimal' do
        model.properties = { lifetime: 1 }

        expect(model.get(:lifetime)).to eql(1)
        expect(model.get(:lifetime)).to be_kind_of(Integer)
      end

      it 'does not cast Floats to BigDecimal' do
        model.properties = { lifetime: 1.0 }

        expect(model.get(:lifetime)).to eql(1.0)
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
    context 'on "use_big_decimal" properties' do
      it 'casts Integers to BigDecimal' do
        model.set(:share, 1)
        expect(model.get(:share)).to eql(BigDecimal.new('1.0'))
      end

      it 'casts Floats to BigDecimal' do
        model.set(:share, 1.0)
        expect(model.get(:share)).to eql(BigDecimal.new('1.0'))
      end

      it 'does not cast nil' do
        model.set(:share, nil)
        expect(model.get(:share)).to be_nil
      end
    end

    context 'on non-"use_big_decimal" properties' do
      it 'does not cast Integers to BigDecimal' do
        model.set(:lifetime, 1)

        expect(model.get(:lifetime)).to eql(1)
        expect(model.get(:lifetime)).to be_kind_of(Integer)
      end

      it 'does not cast Floats to BigDecimal' do
        model.set(:lifetime, 1.0)

        expect(model.get(:lifetime)).to eql(1.0)
        expect(model.get(:lifetime)).to be_kind_of(Float)
      end
    end
  end
end # Refinery::UseBigDecimal
