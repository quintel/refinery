module Refinery::Strategies
  module Demand
    # When the node is an only child (it has a parent which does not supply
    # energy to any other node), and we know what share of the node's energy
    # is supplied by the parent, we can extrapolate the demand of this node.
    #
    # For example, if a parent supplies 50 energy through a link with a share
    # of 0.5, we know that the child must have a demand of 100.
    class OnlyChild
      def self.calculable?(node)
        not exclusive_edge(node).nil?
      end

      def self.calculate(node)
        edge = exclusive_edge(node)

        edge.from.demand / edge.get(:share) /
          node.slots.in(edge.label).get(:share)
      end

      # Internal: Returns the edge which connects the parent to the exclusive
      # child.
      def self.exclusive_edge(node)
        node.in_edges.detect do |edge|
          # Child's only parent is the node being calculated?
          edge.from.out_edges.one? &&
            # And the edge has a share value.
            edge.get(:share) &&
            # And the child node has demand defined.
            edge.from.demand
        end
      end
    end # Only
  end # Demand
end # Refinery::Strategies
