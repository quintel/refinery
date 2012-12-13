module Refinery::Strategies
  module Demand
    # When the node has a child which receives energy exclusively from the
    # node being calculated, and the child and edge have demand and share
    # defined, it is easy to extrapolate the total demand of the parent.
    class FromExclusiveChild
      def self.calculable?(node)
        not exclusive_edge(node).nil?
      end

      def self.calculate(node)
        edge = exclusive_edge(node)
        edge.to.get(:calculator).demand / edge.get(:share)
      end

      # Internal: Returns the edge which connects the parent to the exclusive
      # child.
      def self.exclusive_edge(node)
        node.out_edges.detect do |edge|
          # Child's only parent is the node being calculated?
          edge.to.in_edges.one? &&
            # And the edge has a share value.
            edge.get(:share) &&
            # And the child node has demand defined.
            edge.to.get(:calculator).demand
        end
      end
    end # FromExclusiveChild
  end # Demand
end # Refinery::Strategies
