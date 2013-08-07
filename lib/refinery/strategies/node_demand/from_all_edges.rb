module Refinery::Strategies
  module NodeDemand
    # Calculates the demand of a node when we know the demand of all of its
    # edges, but not their shares or the shares of the slots.
    class FromAllEdges < FromEdges
      def calculable?(node)
        edges = edges(node)
        edges.any? && edges.get(:demand).all?
      end

      def calculate(node)
        edges(node).sum(&:demand)
      end
    end # FromAllEdges
  end # NodeDemand
end # Refinery::Strategies
