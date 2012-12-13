module Refinery::Strategies
  module Share
    # A strategy for calculate edge shares when the node has only a single
    # outbound edge.
    class Solo
      def self.calculable?(edge)
        edge.from.out_edges.one?
      end

      def self.calculate(edge)
        1.0
      end
    end # Solo
  end # Share
end # Refinery::Strategies
