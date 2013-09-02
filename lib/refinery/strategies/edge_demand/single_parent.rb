module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child has
    # only one parent for the edge's carrier.
    class SingleParent
      def self.calculable?(edge)
        edge.to.demand_for(edge.label) && edge.to.in_edges(edge.label).one?
      end

      def self.calculate(edge)
        edge.to.demand_for(edge.label)
      end
    end # SingleParent
  end # EdgeDemand
end # Refinery::Strategies
