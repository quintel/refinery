module Refinery::Strategies
  module Share
    # Calculates an edge share by looking at the demand of the two connected
    # nodes.
    #
    # For example, assume that all four nodes have a demand defined:
    #
    #      A
    #    / | \
    #   B  C  D
    #
    # We can therefore infer the share of each of A's out edges by
    # figuring out what proportion of demand is assigned to each out
    # node. This gets more complicated if one of the out nodes has a
    # second parent; we don't yet handle this.
    class InferFromChild
      def self.calculable?(edge)
        # The child node and it's siblings required demand set...
        edge.from.out.get(:calculator).all?(&:demand) &&
          # The child nodes must each only take demand from the parent.
          edge.from.out.in_edges.all? { |other| other.from == edge.from }
      end

      def self.calculate(edge)
        others = edge.from.out.uniq.inject(0.0) do |sum, node|
          sum + node.get(:calculator).demand
        end

        edge.to.get(:calculator).demand / others
      end
    end # InferFromChild
  end # Share
end # Refinery::Strategies
