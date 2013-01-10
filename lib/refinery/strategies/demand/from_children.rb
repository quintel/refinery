module Refinery::Strategies
  module Demand
    # A strategy for calculating the demand of a node when we know the shares
    # of all the outgoing edges, and the demands of the child nodes.
    class FromChildren
      def self.calculable?(node)
        node.out.any? && node.out_edges.all?(&:demand)
      end

      def self.calculate(node)
        node.out_edges.sum(&:demand)
      end
    end # FromChildren
  end # Demand
end # Refinery::Strategies
