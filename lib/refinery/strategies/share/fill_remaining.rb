module Refinery::Strategies
  module Share
    # A strategy for calculate edge shares when all of the node's other
    # outbound edges have a share.
    class FillRemaining
      def self.calculable?(edge)
        edge.from.out_edges.all? do |other|
          other.similar?(edge) || other.get(:share)
        end
      end

      def self.calculate(edge)
        1.0 - edge.from.out_edges.inject(0.0) do |sum, other|
          sum + (other.get(:share) || 0.0)
        end
      end
    end # OnlyEdge
  end # Share
end # Refinery::Strategies
