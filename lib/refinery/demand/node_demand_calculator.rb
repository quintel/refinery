module Refinery
  module Demand
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class NodeDemandCalculator < Calculator
      STRATEGIES = [
        Strategies::Demand::FromChildren,
        Strategies::Demand::OnlyChild,
        Strategies::Demand::FromParents,
        Strategies::Demand::FillRemaining
      ]

      # Public: Performs the calculation, setting the demand attribute on the
      # node.
      #
      # Returns nothing.
      def calculate!(order)
        @model.set(demand_attribute, strategy.calculate(@model))
        super
      end

      # Public: Has a demand value been set for the node?
      #
      # Returns true or false.
      def calculated?
        super || @model.get(demand_attribute)
      end

      # Public: Determines on which attribute to store the node's demand.
      # Nodes with no descendants use :preset_demand, while others have their
      # demand set to :expected_demand.
      #
      # Returns a symbol.
      def demand_attribute
        @attr ||= @model.out_edges.none? ? :preset_demand : :expected_demand
      end
    end # NodeDemandCalculator
  end # Demand
end # Refinery
