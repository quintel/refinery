module Refinery::Strategies
  module Demand
    # A strategy for calculate edge shares when all of the node's other
    # outbound edges have a share.
    class FromChildren
      def self.calculable?(node)
        node.out.any? &&
          node.out.get(:calculator).all?(&:demand) &&
          node.out.in_edges.all? { |edge| edge.from == node } &&
          node.out.in_edges.get(:share).all?
      end

      def self.calculate(node)
        node.out_edges.sum do |edge|
          share_of_input(edge) * edge.to.get(:calculator).demand
        end
      end

      # Internal: Given an edge, calculates the proportion of the "to" node's
      # energy it supplies.
      #
      # edge - The edge.
      #
      # Returns a float.
      def self.share_of_input(edge)
        edge.get(:share) / edge.to.in_edges.get(:share).sum
      end
    end # FromChildren

    class FromExclusiveChild
      def self.calculable?(node)
        not single_child(node).nil?
      end

      def self.calculate(node)
        edge = single_child(node)
        edge.to.get(:calculator).demand / edge.get(:share)
      end

      def self.single_child(node)
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
