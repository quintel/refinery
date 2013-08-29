module Refinery
  module Diagram
    class Focused < Base
      def initialize(graph, focused_element)
        super(graph)
        @focused_element = focused_element
      end

      #######
      private
      #######

      def edge_options(edge)
        super.merge(penwidth: edge == @focused_element ? 4.0 : 1.0)
      end

      def node_options(node)
        super.merge(penwidth: node == @focused_element ? 3.0 : 1.0)
      end
    end # Focused
  end # Diagram
end # Refinery