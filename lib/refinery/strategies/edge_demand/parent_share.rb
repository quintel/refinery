module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child has
    # only one parent for the edge's carrier.
    class ParentShare
      def self.calculable?(edge)
        edge.from.demand && edge.parent_share
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label) * edge.parent_share
      end
    end # ParentShare
  end # EdgeDemand
end # Refinery::Strategies
