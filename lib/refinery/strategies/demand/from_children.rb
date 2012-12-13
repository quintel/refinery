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
 end # Demand
end # Refinery::Strategies
