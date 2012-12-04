module Refinery
  module Demand
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class NodeDemandCalculator < Calculator
      # Public: Determines if demand can be calculated for the node.
      #
      # Returns true or false.
      def calculable?
        not strategy.nil?
      end

      # Public: Helper method which returns the demand assigned to the node.
      #
      # Returns a float or nil if no demand has been assigned yet.
      def demand
        @model.get(demand_attribute)
      end

      # Public: Calculates and sets the demand for the node.
      #
      # Returns true.
      def calculate!
        @model.set(demand_attribute, __send__(:"calculate_#{ strategy }"))

        super
      end

      # Public: Has a demand value been set for the node?
      #
      # Returns true or false.
      def calculated?
        super || @model.get(demand_attribute)
      end

      #######
      private
      #######

      # Internal: Which strategy should be used to calculate the node demand.
      #
      # Depending on the state of "nearby" nodes end edges, there are
      # different ways we can compute the demand.
      #
      # Returns the strategy name as a symbol, or nil if there is currently no
      # way to compute the value.
      def strategy
        if demand_from_parents?
          :from_parents
        elsif demand_from_children?
          :from_children
        end
      end

      # Internal: If the parent has demand defined, and the link connecting
      # the two nodes has a share, we can easily calculte this node's demand.
      #
      # Returns true or false.
      def demand_from_parents?
        @model.in_edges.any? && @model.in_edges.all? do |edge|
          edge.get(:share) && edge.from.get(:calculator).demand
        end
      end

      # Internal: Calculates demand using the parent nodes.
      #
      # Returns a float.
      def calculate_from_parents
        @model.in_edges.reduce(0) do |sum, edge|
          sum + (edge.get(:share) * edge.from.get(:calculator).demand)
        end
      end

      # Internal: If all of the nodes children have demand, and their edges
      # have a share, we can calculate demand.
      #
      # Returns true or false.
      def demand_from_children?
        @model.out.any? &&
          @model.out.get(:calculator).all?(&:demand) &&
          @model.out.in_edges.get(:share).all?
      end

      # Internal: Calculates demand using the child nodes.
      #
      # Returns a float.
      def calculate_from_children
        @model.out_edges.reduce(0) do |sum, edge|
          sum + share_of_input(edge) * edge.to.get(:calculator).demand
        end
      end

      # Internal: Determines on which attribute to store the node's demand.
      # Nodes with no descendants use :preset_demand, while others have their
      # demand set to :expected_demand.
      #
      # Returns a symbol.
      def demand_attribute
        @model.out_edges.none? ? :preset_demand : :expected_demand
      end

      # Internal: Given an edge, calculates the proportion of the "to" node's
      # energy it supplies.
      #
      # edge - The edge.
      #
      # Returns a float.
      def share_of_input(edge)
        edge.get(:share) /
          edge.to.in_edges.get(:share).reduce(0) { |sum, value| sum + value }
      end
    end # NodeDemandCalculator
  end # Demand
end # Refinery
