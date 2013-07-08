module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculating edge demand when all of the node's other
    # outbound edges of the same carrier already have a demand calculated.
    #
    # For example, in this simple case:
    #
    #    [A] [B]
    #      \ / (5)
    #      [X] (20)
    #
    # ... we know that B->X has a demand of 5, therefore A->X must have a
    # demand of 20 (so that that all edges meet the demand of [X]).
    class FillRemaining
      def self.calculable?(edge)
        child_demand(edge) &&
          edge.to.slots.in(edge.label).share &&
          edge.to.in_edges(edge.label).all? do |other|
            other.similar?(edge) || other.get(:demand)
          end
      end

      def self.calculate(edge)
        demand = child_demand(edge) * edge.to.slots.in(edge.label).share
        supply = edge.to.in_edges(edge.label).get(:demand).to_a.compact.sum

        if demand >= supply
          demand - supply
        else
          # Node already has too much energy; this edge should be zero, and
          # we assume that there is an overflow edge which will take away the
          # excess.
          0.0
        end
      end

      # Internal: Given an edge, determines the demand of the child node.
      #
      # This will preferentially return the node's +demand+ attribute if it
      # has one, otherwise it will see if all of the nodes out edges (minus
      # those with the "overflow" behaviour) have a known demand. This allows
      # it to act like ETEngine's "flexible" links.
      #
      # Returns a numeric, or nil if no demand can be determined.
      def self.child_demand(edge)
        edge.to.demand
      end
    end # FillRemaining
  end # EdgeDemand
end # Refinery::Strategies
