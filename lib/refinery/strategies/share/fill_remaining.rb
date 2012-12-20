module Refinery::Strategies
  module Share
    # A strategy for calculate edge shares when all of the node's other
    # outbound edges of the same carrier already have a share.
    class FillRemaining
      def self.calculable?(edge)
        edge.from.out_edges(edge.label).all? do |other|
          other.similar?(edge) || other.get(:share)
        end
      end

      def self.calculate(edge)
        1.0 - edge.from.out_edges(edge.label).get(:share).to_a.compact.sum
      end
    end # OnlyEdge
  end # Share
end # Refinery::Strategies
