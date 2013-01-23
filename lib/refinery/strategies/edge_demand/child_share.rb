module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child node
    # has demand defined, and we know the child share of the edge.
    class ChildShare
      def self.calculable?(edge)
        edge.to.demand && edge.child_share
      end

      def self.calculate(edge)
        edge.to.demand_for(edge.label) * edge.child_share
      end
    end # ChildShare
  end # EdgeDemand
end # Refinery::Strategies
