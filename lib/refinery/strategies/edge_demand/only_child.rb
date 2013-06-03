module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child node
    # receives carrier energy exclusively from the parent node.
    class OnlyChild
      def self.calculable?(edge)
        edge.from.demand &&
          edge.from.out_edges(edge.label).one? &&
          edge.from.slots.out(edge.label).share
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label)
      end
    end # OnlyChild
  end # EdgeDemand
end # Refinery::Strategies
