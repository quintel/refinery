module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculating edge demand when all of the node's other
    # outbound edges of the same carrier already have a demand.
    #
    # For example, in this simple case:
    #
    #      [A] (20)
    #      / \ (5)
    #    [X] [Y]
    #
    # ... we know that A->Y has a demand of 5, therefore A->X must have a
    # demand of 15 in order to use up all of the energy output by [A].
    class FillRemainingFromParent
      def self.calculable?(edge)
        edge.from.output_of(edge.label) &&
          edge.from.out_edges(edge.label).all? do |other|
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
