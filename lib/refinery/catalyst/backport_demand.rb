module Refinery
  module Catalyst
    class BackportDemand

      # Public: Calculates expected demand for any nodes whose values have not
      # yet been filled in.
      #
      # graph - The graph whose demand values are to be calculated.
      #
      # Returns nothing.
      def self.call(graph)
        demand_nodes = graph.tsort.reject do |node|
          node.get(:expected_demand) || node.get(:preset_demand)
        end

        demand_nodes.each { |node| new(node).calculate! }

        nil
      end

      # Public: Creates a new backporting demand calculation. Takes a single
      # node and assigns an "expected_demand" value based on the demand of
      # it's outgoing nodes.
      #
      # node - The node to be assigned a demand value.
      #
      # Returns a BackportDemand.
      def initialize(node)
        @node = node
      end

      # Public: Performs the calculation, assigning the node a demand based on
      # it's outgoing nodes.
      #
      # Raises an error if one or more of the out nodes does not have a demand
      # value.
      #
      # Returns nothing.
      def calculate!
        return false unless can_calculate?

        demand = 0.0

        @node.out_edges.each do |edge|
          demand += proportional_share_of(edge) *
            (edge.to.get(:final_demand) || edge.to.get(:expected_demand))
        end

        @node.set(:expected_demand, demand)
      end

      #######
      private
      #######

      # Internal: Given a link, calculates the proportion of the "in" nodes
      # energy it supplies.
      #
      # edge - The edge.
      #
      # Returns a numeric.
      def proportional_share_of(edge)
        edge.get(:share) / edge.to.in_edges.get(:share).
          inject(0) { |sum, value| sum + value }
      end

      # Internal: Determines if there is enough information to calculate the
      # demand for this node based on the demand of its descendants.
      #
      # Returns true or false.
      def can_calculate?
        # If the "out" nodes do not have a "share" on all of their "in" edges,
        # there's no way to determine this node's demand.
        @node.out.in_edges.get(:share).all?
      end

    end # BackportDemand
  end # Catalyst
end # Refinery
