module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child has
    # only one parent for the edge's carrier.
    class OutputShare
      def self.calculable?(edge)
        edge.from.demand && edge.get(:output_share)
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label) * edge.get(:output_share)
      end
    end # OutputShare
  end # EdgeDemand
end # Refinery::Strategies
