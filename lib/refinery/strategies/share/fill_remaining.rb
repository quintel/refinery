module Refinery::Strategies
  module Share
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
    class FillRemaining
      def self.calculable?(edge)
        edge.to.in_edges(edge.label).all? do |other|
          other.similar?(edge) || other.get(:share)
        end
      end

      def self.calculate(edge)
        1.0 - edge.to.in_edges(edge.label).get(:share).to_a.compact.sum
      end
    end # FillRemaining
  end # Share
end # Refinery::Strategies
