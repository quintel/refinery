module Refinery::Strategies
  module Demand
    # A strategy for calculate edge shares when all of the node's other
    # outbound edges have a share.
    class FromParents
      def self.calculable?(node)
        node.in_edges.any? &&
          node.in_edges.map(&:demand).all?
      end

      def self.calculate(node)
        node.in_edges.map(&:demand).sum
      end
    end # FromParents
  end # Demand
end # Refinery::Strategies
