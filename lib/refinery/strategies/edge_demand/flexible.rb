module Refinery::Strategies
  module EdgeDemand
    class Flexible < FillRemaining
      # Internal: Given an edge, determines the demand of the child node.
      #
      # This will preferentially return the node's +demand+ attribute if it
      # has one, otherwise it will see if all of the nodes out edges (minus
      # those with the "overflow" behaviour) have a known demand. This allows
      # it to act like ETEngine's "flexible" links.
      #
      # Returns a numeric, or nil if no demand can be determined.
      def self.child_demand(edge)
        super(edge) ||
          Refinery::Util.strict_sum(edge.to.out_edges.select do |other|
            other.demand || other.get(:type) != :overflow
          end, &:demand)
      end
    end # Flexible
  end # EdgeDemand
end # Refinery::Strategies
