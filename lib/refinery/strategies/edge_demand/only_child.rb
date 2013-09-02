module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when the child node
    # receives carrier energy exclusively from the parent node.
    class OnlyChild
      def self.calculable?(edge)
        # We know the demand of the parent and child nodes.
        edge.to.demand_for(edge.label) &&
          edge.from.output_of(edge.label) &&
          # ... and this is the only edge which carries this type of energy
          # (ignoring overflow edges which will take any excess away).
          edge.from.out_edges(edge.label).reject do |other|
            other.get(:type) == :overflow
          end.one?
      end

      def self.calculate(edge)
        demand = edge.to.demand_for(edge.label)
        supply = edge.from.output_of(edge.label)

        (demand && demand < supply) ? demand : supply
      end
    end # OnlyChild
  end # EdgeDemand
end # Refinery::Strategies
