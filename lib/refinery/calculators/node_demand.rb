module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class NodeDemand < Base
      STRATEGIES = [
        Strategies::NodeDemand::FromChildren,
        Strategies::NodeDemand::OnlyChild,
        Strategies::NodeDemand::FromParents,
        Strategies::NodeDemand::FillRemaining
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
        super || @model.get(:demand)
      end
    end # NodeDemand
  end # Calculators
end # Refinery
