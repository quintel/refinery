module Refinery::Strategies
  module NodeDemand
    # A strategy for calculating the demand of a node when we know the demand
    # of all its parents, and the shares of all incoming edges.
    class FromParents
      def self.calculable?(node)
        node.in_edges.any? && node.in_edges.all?(&:demand)
      end

      def self.calculate(node)
        node.in_edges.sum(&:demand)
      end
    end # FromParents
  end # NodeDemand
end # Refinery::Strategies
