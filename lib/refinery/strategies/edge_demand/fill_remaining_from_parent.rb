module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculating edge shares when all of the node's other
    # outbound edges of the same carrier already have a share.
    #
    # For example, in this simple case:
    #
    #    [A] [B]
    #      \ / (0.2)
    #      [X]
    #
    # ... we know that B->X has a share of 0.2, therefore A->X must have a
    # share of 0.8 (so that that all shares combined sum to 1.0).
    class FillRemainingFromParent
      def self.calculable?(edge)
        edge.from.demand && edge.from.out_edges(edge.label).all? do |other|
          other.similar?(edge) || other.get(:demand)
        end
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label) -
          edge.from.out_edges(edge.label).get(:demand).to_a.compact.sum
      end
    end # FillRemaining
  end # EdgeDemand
end # Refinery::Strategies
