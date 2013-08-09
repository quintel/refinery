module Refinery::Strategies
  module NodeDemand
    # An abstract strategy used to write other strategies which can work in
    # both +directions+ -- in and out -- based on the edges and slots of a
    # node.
    #
    # FromEdges takes a single argument, +:in+ or +:out+ to configure in which
    # direction to look (in slots and edges, or out slots and edges).
    class FromEdges
      # Public: Creates a FromEdges strategy. Specify the +direction+ of the
      # slots and edges you want to use.
      def initialize(direction)
        @direction = direction.to_sym
      end

      # Public: A human-readable version of the strategy.
      #
      # Returns a string.
      def inspect
        "#<#{ self.class.name } (#{ @direction.inspect })>"
      end

      #######
      private
      #######

      def share(edge)
        @direction == :in ? edge.child_share : edge.parent_share
      end

      def slots(node)
        @direction == :in ? node.slots.in : node.slots.out
      end

      def edges(node)
        @direction == :in ? node.in_edges : node.out_edges
      end
    end # FromEdges
  end # NodeDemand
end # Refinery::Strategies
