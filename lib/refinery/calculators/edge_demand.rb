module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class EdgeDemand < Base
      STRATEGIES = [
        Strategies::EdgeDemand::SingleParent,
        Strategies::EdgeDemand::FromDemand,
        Strategies::EdgeDemand::FillRemaining,
        Strategies::EdgeDemand::FillRemainingFromParent,
        Strategies::EdgeDemand::OnlyChild,
        Strategies::EdgeDemand::OutputShare,
        Strategies::EdgeDemand::Share
      ]

      # Public: Performs the calculation, setting the demand attribute on the
      # node.
      #
      # Returns nothing.
      def calculate!(order)
        @model.set(:demand, strategy.calculate(@model))
        super
      end

      # Public: Has a demand value been set for the node?
      #
      # Returns true or false.
      def calculated?
        super || @model.get(:demand) || @model.get(:share)
      end
    end # EdgeDemand
  end # Calculators
end # Refinery
