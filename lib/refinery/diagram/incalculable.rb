module Refinery
  module Diagram
    # A diagram which shows the incalculable nodes and edges normally, and all
    # other elements mostly transparent.
    class Incalculable < Base
      include Transparency

      private

      def edge_options(edge)
        recolor_options(super, edge.demand)
      end

      def node_options(node)
        recolor_options(super, node.demand)
      end

      def edge_label(edge)
        recolor_label(super, edge.demand)
      end

      def node_label(node)
        recolor_label(super, node.demand)
      end
    end # Incalculable
  end # Diagram
end # Refinery
