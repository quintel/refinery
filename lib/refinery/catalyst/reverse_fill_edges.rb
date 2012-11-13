module Refinery
  module Catalyst
    class ReverseFillEdges

      # Public: Given a graph, calculates the "share" value for edges where
      # its out nodes have a demand value defined.
      #
      # graph - The graph whose edge shares are to be calculated.
      #
      # Returns nothing.
      def self.call(graph)
        graph.nodes.each do |node|
          blank_edges = node.out_edges.select { |edge| edge.get(:share).nil? }
          blank_edges.each { |edge| new(edge).calculate! }
        end

        nil
      end

      # Public: Creates a new catalyst for calculating the share values of
      # edges from left-to-right using the demand of the child nodes.
      #
      # edge - The edge whose share is to be calculated.
      #
      # Returns a new ReverseFillEdges.
      def initialize(edge)
        @edge = edge
      end

      # Public: Performs the calculation, setting the share value. No share
      # will be set if one or more of the child's siblings do not have a
      # demand defined.
      #
      # Returns nothing.
      def calculate!
        # All of the nodes which the edge's "out" node links to.
        sibling_children = @edge.out.out.uniq

        # Share can only be calculated if all of of the child's siblings have
        # a demand available.
        if sibling_children.all? { |child| demand_of(child) }
          total_parent_demand = sum_demand(sibling_children)

          @edge.set(:share, demand_of(@edge.in) / total_parent_demand)
        end
      end

      #######
      private
      #######

      # Internal: Given a node, returns its demand.
      #
      # Returns a float, or nil if no demand is defined.
      def demand_of(node)
        node.get(:expected_demand) ||
          node.get(:preset_demand) ||
          node.get(:final_demand)
      end

      # Internal: Given one or more nodes, returns the sum of all their
      # demands.
      #
      # Returns a float.
      def sum_demand(nodes)
        nodes.inject(0) { |sum, node| sum + demand_of(node) }
      end

    end # ReverseFillEdges
  end # Catalyst
end # Refinery
