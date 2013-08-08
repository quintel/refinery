module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class NodeDemand < Base
      DEFAULT_STRATEGIES = [
        Strategies::NodeDemand::FromCompleteEdge.new(:out),
        Strategies::NodeDemand::FromCompleteEdge.new(:in),
        Strategies::NodeDemand::FromCompleteSlot.new(:out),
        Strategies::NodeDemand::FromCompleteSlot.new(:in),
        Strategies::NodeDemand::FromAllEdges.new(:out),
        Strategies::NodeDemand::FromAllEdges.new(:in),
        Strategies::NodeDemand::FromPartialSlot.new(:out),
        Strategies::NodeDemand::FromPartialSlot.new(:in),
        Strategies::NodeDemand::OnlyChild
      ]

      # Public: Performs the calculation, setting the demand attribute on the
      # node.
      #
      # Returns nothing.
      def calculate!(order)
        super
        @model.set(:demand, strategy.calculate(@model))
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
