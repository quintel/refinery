module Refinery
  module Catalyst
    class CalculateDemand

      # Public: Calculates expected and preset demand for the graph by
      # traversing from nodes with a "final_demand" attribute.
      #
      # graph - The graph whose demand values are to be calculated.
      #
      # Returns nothing.
      def self.call(graph)
        demand_nodes = graph.tsort.reject do |node|
          node.get(:final_demand).nil?
        end

        demand_nodes.each { |node| new(node).calculate! }

        nil
      end

      # Public: Creates a new demand calculation. Takes a single node and
      # traverses it's outward links to assign demand based on the "share" of
      # each edge.
      #
      # node - The "final_demand" node.
      #
      # Returns a CalculateDemand.
      def initialize(node)
        @node = node
      end

      # Public: Performs the calculation, assigning demand to each node's
      # outward nodes.
      #
      # Returns nothing.
      def calculate!
        @node.descendants.select { |n| can_calculate?(n) }.each do |node|
          node.set(demand_attribute(node), calculate_demand(node))
        end
      end

      #######
      private
      #######

      # Internal: Returns the attribute to which the demand attribute should
      # be saved. Leaf nodes set :preset demand while others use :expected.
      #
      # Returns a symbol.
      def demand_attribute(node)
        leaf?(node) ? :preset_demand : :expected_demand
      end

      # Internal: Determines if a node has all the data required in order for
      # demand to be calculated.
      #
      # Returns true or false.
      def can_calculate?(node)
        node.in_edges.none? do |edge|
          edge.get(:share).nil? || demand_of(edge.from).nil?
        end
      end

      # Internal: Given a node, calculates its demand based its ancestors and
      # the "share" of each edge which connect them.
      #
      # Returns a float.
      def calculate_demand(node)
        node.in_edges.inject(0) do |sum, edge|
          sum + (edge.get(:share) * demand_of(edge.from))
        end
      end

      # Internal: Returns if the given node is a leaf (has no descendants).
      #
      # Returnst true or false.
      def leaf?(node)
        node.out_edges.none?
      end

      # Internal: Given a node, returns its demand.
      #
      # Returns a float, or nil if no demand is defined.
      def demand_of(node)
        node.get(:expected_demand) ||
          node.get(:preset_demand) ||
          node.get(:final_demand)
      end

    end # CalculateDemand
  end # Catalyst
end # Refinery
