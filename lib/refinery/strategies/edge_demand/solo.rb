module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculate edge shares when the node has only a single
    # inbound edge.
    class Solo
      def self.calculable?(edge)
        edge.to.in_edges(edge.label).one? && edge.to.demand
      end

      def self.calculate(edge)
        edge.to.demand * edge.to.slots.in(edge.label).get(:share)
      end
    end # Solo
  end # EdgeDemand
end # Refinery::Strategies
