module Refinery::Strategies
  module EdgeDemand
    # A strategy which calcualtes the demand of an edge when we know the
    # output of the parent, and also have a parent share defined on the edge.
    class ParentShare
      def self.calculable?(edge)
        edge.from.output_of(edge.label) && edge.parent_share
      end

      def self.calculate(edge)
        edge.from.output_of(edge.label) * edge.parent_share
      end
    end # ParentShare
  end # EdgeDemand
end # Refinery::Strategies
