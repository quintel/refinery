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
        @node.descendants.each do |node|
          attr = node.out_edges.any? ? :expected_demand : :preset_demand
          node.set(attr, 0.0)

          node.in_edges.each do |edge|
            edge_demand = edge.get(:share) *
              (edge.out.get(:final_demand) || edge.out.get(:expected_demand))

            node.set(attr, node.get(attr) + edge_demand)
          end
        end
      end

    end # CalculateDemand
  end # Catalyst
end # Refinery
