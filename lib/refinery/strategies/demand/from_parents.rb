module Refinery::Strategies
  module Demand
    # A strategy for calculating the demand of a node when we know the demand
    # of all its parents, and the shares of all incoming edges.
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
