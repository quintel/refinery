module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child node
    # has demand defined, and we know the child share of the edge.
    #
    #   [A] [B]
    #     \ / (child_share:0.5)
    #     [X] (50)
    #
    # Here we can work out that the demand of B->X is 25 since it provides
    # half of the carrier energy demanded by [X].
    class ChildShare
      def self.calculable?(edge)
        edge.to.demand_for(edge.label) && edge.child_share
      end

      def self.calculate(edge)
        edge.to.demand_for(edge.label) * edge.child_share
      end
    end # ChildShare
  end # EdgeDemand
end # Refinery::Strategies
