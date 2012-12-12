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
        1.0 - edge.from.out_edges.sum { |edge| edge.get(:share) || 0.0 }
      end
    end # OnlyEdge
  end # Share
end # Refinery::Strategies
