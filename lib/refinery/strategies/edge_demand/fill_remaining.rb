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
        edge.to.demand && edge.to.in_edges(edge.label).all? do |other|
          other.similar?(edge) || other.get(:demand)
        end
      end

      def self.calculate(edge)
        edge.to.demand_for(edge.label) -
          edge.to.in_edges(edge.label).get(:demand).to_a.compact.sum
      end
    end # FillRemaining
  end # EdgeDemand
end # Refinery::Strategies
