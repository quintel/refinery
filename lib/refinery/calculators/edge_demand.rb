module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class EdgeDemand < Base
      DEFAULT_STRATEGIES = [
        Strategies::EdgeDemand::SingleParent,
        Strategies::EdgeDemand::OnlyChild,
        Strategies::EdgeDemand::FromDemand,
        Strategies::EdgeDemand::FromChildDemand,
        Strategies::EdgeDemand::FillRemaining,
        Strategies::EdgeDemand::FillRemainingFromParent,
        Strategies::EdgeDemand::ParentShare,
        Strategies::EdgeDemand::ChildShare
      ]

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

      #######
      private
      #######

      # Internal: An array containing the strategies which may be used to
      # calculate the edge.
      #
      # Returns an array of strategies.
      def applicable_strategies
        case @model.get(:type)
        when :overflow
          [ Strategies::EdgeDemand::Overflow,
            Strategies::EdgeDemand::SingleParent ]
        when :flexible
          [ Strategies::EdgeDemand::OnlyChild,
            Strategies::EdgeDemand::ParentShare,
            Strategies::EdgeDemand::ChildShare,
            Strategies::EdgeDemand::Flexible ]
        else
          super
        end
      end
    end # EdgeDemand
  end # Calculators
end # Refinery
