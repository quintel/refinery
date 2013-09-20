module Refinery::Strategies
  # Provides helpful methods for creating strategies which can be calculated
  # in either direction.
  module Reversible
    def self.included(base)
      base.instance_eval { extend(ClassMethods) }
    end

    # Public: The strategy as a string.
    #
    # Returns a string.
    def to_s
      reversed? ? "#{ self.class.name } (reversed)" : self.class.name
    end

    # Public: A human-readable version of the strategy.
    #
    # Returns a string.
    def inspect
      "#<#{ to_s }>"
    end

    # Public: Is the strategy being executed in reverse mode? "forwards" is
    # defined in the Forwards and Reversed modules.
    #
    # Returns true or false.
    def reversed?
      ! forwards?
    end

    module ClassMethods
      # Public: Creates a new class, based on "self", mixing in the module
      # which controls the direction in which the calculation works.
      #
      # Returns a class.
      def compile(direction)
        klass = Class.new(self)
        name  = name

        klass.instance_eval do
          include(direction == :forwards ? Forwards : Reversed)
        end

        klass
      end

      # Public: Creates a new instance of the strategy, raising an error if
      # the user forgot to +compile+ a version to give the strategy 
      # direction.
      #
      # Returns the strategy.
      def new
        unless (ancestors & [Forwards, Reversed]).any?
          raise(UncompiledReversibleError.new(self))
        end

        super
      end

      # Public: The name of the strategy.
      #
      # Returns a string.
      def name
        ancestors[ancestors.index(Reversible) - 1].inspect
      end
    end # ClassMethods
  end # Reversible
end # Refinery::Strategies
