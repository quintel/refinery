module Refinery::Strategies
  module Demand
    # A strategy for calculate edge shares when all of the node's other
    # outbound edges have a share.
    class FromParents
      def self.calculable?(node)
        node.in_edges.any? && node.in_edges.all? do |edge|
          edge.get(:share) && edge.from.get(:calculator).demand
        end
      end

      def self.calculate(node)
        node.in_edges.reduce(0) do |sum, edge|
          sum + (edge.get(:share) * edge.from.get(:calculator).demand)
        end
      end
    end # FromParents
  end # Demand
end # Refinery::Strategies
