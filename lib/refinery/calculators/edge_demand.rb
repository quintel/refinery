module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class EdgeDemand < Base
      include Strategies::EdgeDemand

      DEFAULT_STRATEGIES = [
        ByShare.forwards.new,
        ByShare.reversed.new,
        Solo.forwards.new,
        Solo.reversed.new,
        FillRemaining.forwards.new,
        FillRemaining.reversed.new,
        FillRemainingAcrossSlots.forwards.new,
        FillRemainingAcrossSlots.reversed.new
      ].freeze

      OVERFLOW_STRATEGIES = [
        Overflow.new,
        Solo.reversed.new
      ].freeze

      FLEXIBLE_STRATEGIES = [
        Solo.forwards.new,
        FillRemaining.forwards.new,
        Flexible.new,
        ByShare.forwards.new,
        ByShare.reversed.new
      ].freeze

      # Public: Performs the calculation, setting the demand attribute on the
      # node.
      #
      # Returns nothing.
      def calculate!(order)
        super

        @model.set(:demand, [
          # Disallow the calculated value from exceeding the demand specified
          # by the node -- assuming we already know what that demand is.
          strategy.calculate(@model),
          @model.to.demand_for(@model.label),
          @model.from.output_of(@model.label)
        ].compact.min)
      end

      # Public: Has a demand value been set for the node?
      #
      # Returns true or false.
      def calculated?
        super || @model.demand
      end

      private

      # Internal: An array containing the strategies which may be used to
      # calculate the edge.
      #
      # Returns an array of strategies.
      def applicable_strategies
        case @model.get(:type)
        when :overflow then OVERFLOW_STRATEGIES
        when :flexible then FLEXIBLE_STRATEGIES
        else                super
        end
      end
    end
  end
end
