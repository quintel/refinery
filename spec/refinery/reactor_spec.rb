require 'spec_helper'

describe Refinery::Reactor do
  context 'given no catalysts' do
    let(:reactor) { Refinery::Reactor.new([]) }

    it 'does nothing' do
      expect(reactor.run('abc')).to eql('abc')
    end
  end # given no catalysts

  context 'given two lambda catalysts' do
    let(:reactor) do
      Refinery::Reactor.new(
        ->(x) { x.reverse! }, ->(x) { x.upcase! })
    end

    it 'runs each catalyst in turn' do
      expect(reactor.run('abc')).to eql('CBA')
    end

    it 'modifies the argument in-place' do
      str = 'abc'
      reactor.run(str)

      expect(str).to eql('CBA')
    end
  end # given two lambda catalysts

  context 'given an object catalyst which reponds to #call' do
    let(:reactor) do
      Refinery::Reactor.new(Class.new do
        def call(str) ; str.upcase! ; end
      end.new)
    end

    it 'runs the catalysts #call method' do
      expect(reactor.run('abc')).to eql('ABC')
    end
  end # given an object catalyst which reponds to #call

  context 'given an object catalyst which does not respond to #call' do
    let(:reactor) { Refinery::Reactor.new(:nope) }

    it 'raises NoMethodError' do
      expect { reactor.run('abc') }.to raise_error(NoMethodError)
    end
  end # given an object catalyst which does not respond to #call
end # Refinery::Reactor
