module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculate edge shares when the node has only a single
    # outbound edge.
    class OutputShare
      def self.calculable?(edge)
        edge.from.demand && edge.from.out_edges(edge.label).one?
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label)
      end
    end # OutputShare
  end # EdgeDemand
end # Refinery::Strategies
