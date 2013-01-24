module Refinery
  module Calculators
    # For demand calculations, each node and edge receive a calculator which
    # is capable of assigning the necessary values (such as expected demand,
    # link share, etc).
    class Base
      # Public: Returns the strategy which was used to calculate the
      # attribute or nil if no calculation has been performed yet.
      attr_reader :strategy_used

      # Public: Returns an integer indicating the order in which the
      # calculators were evalulated.
      attr_reader :order

      # Public: The object which the calculator calculates.
      attr_reader :model

      # Public: Creates a new calculator responsible for figuring out the
      # unknown attributes for the given +model+. Calculator is a base class
      # and should be extended with the logic needed to compute the values.
      #
      # model - The Turbine node or edge.
      #
      # Returns a Calculator.
      def initialize(model)
        @model         = model
        @calculated    = false
        @strategy_used = nil
        @order         = nil
      end

      # Public: Does the instance have all the data it needs to perform its
      # calculation?
      #
      # Returns true or false.
      def calculable?
        not strategy.nil?
      end

      # Public: Performs the calculation, setting the appropriate attributes
      # on the model.
      #
      # order - This is the +order+'th calculator to be run. 1 would be the
      #         first calculator, 5 the fifth, etc.
      #
      # Returns nothing.
      def calculate!(order)
        @strategy_used = strategy
        @order         = order
        @calculated    = true
      end

      # Public: Returns if the calculator has previously been successfully
      # run.
      #
      # Returns true or false.
      def calculated?
        @calculated
      end

      # Public: A human-readable version of the calculator for debugging.
      #
      # Returns a string.
      def inspect
        head = "#<#{ self.class.name } model=#{ @model.inspect }"

        if @strategy_used
          "#{ head } order=#{ @order } strategy_used=#{ @strategy_used }>"
        else
          "#{ head } (not calculated)>"
        end
      end

      # Public: A pretty version of the calculator.
      #
      # Returns a string.
      def to_s
        "#{ self.class.name.gsub(/.+::/, '') } for #{ @model.inspect }"
      end

      #######
      private
      #######

      # Internal: Which strategy should be used to calculate the value.
      #
      # Depending on the state of "nearby" elements (related nodes and edges)
      # there are different ways to perform the computation.
      #
      # Returns the strategy, or nil if there is no way to currently calculate
      # the value.
      def strategy
        self.class::STRATEGIES.detect { |strat| strat.calculable?(@model) }
      end
    end # Base
  end # Calculators
end # Refinery
