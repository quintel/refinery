module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child node
    # has demand defined, and we know the share of the edge.
    class Share
      def self.calculable?(edge)
        edge.to.demand && edge.share
      end

      def self.calculate(edge)
        edge.to.demand_for(edge.label) * edge.share
      end
    end # Share
  end # EdgeDemand
end # Refinery::Strategies
