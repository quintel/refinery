module Refinery::Strategies
  module EdgeDemand
    # A variation on FromDemand which works by filling in the demand required
    # by a child node, instead of a parent.
    #
    # See FromDemand.
    class FromChildDemand
      def self.calculable?(edge)
        # Parent and child demand?
        edge.to.demand && edge.from.demand &&
          # We already know how the child node receives energy from its other
          # parents?
          (edge.to.in_edges.to_a - [edge]).all?(&:demand)
      end

      def self.calculate(edge)
        new(edge).calculate
      end

      # Public: Creates a new FromChildDemand strategy which seeks to
      # intelligently infer the demand of an edge by looking at the demands
      # of the parent and child nodes, and their relatives.
      #
      # edge - The edge whose demand is to be calculated.
      #
      # Returns a FromDemand.
      def initialize(edge)
        @edge = edge
      end

      # Public: Runs the calculation, returning the demand value for the edge.
      #
      # Returns a float.
      def calculate
        demand = unfulfilled_demand
        supply = unassigned_supply

        demand < supply ? demand : supply
      end

      #######
      private
      #######

      # Internal: Calculates how much of the child's energy supply is
      # yet to be assigned to an incoming edge.
      #
      # Returns a float.
      def unfulfilled_demand
        @edge.to.demand - related_child_edges.sum(&:demand)
      end

      # Internal: Calculates how much energy can be provided by the parent
      # node. This is it's demand minus that which is already assigned to
      # other outgoing edges.
      #
      # Returns a float.
      def unassigned_supply
        existing_supply = 0.0

        if related_parent_edges
          # If the child element has other parents, and we already know their
          # demand, we will reduce the unfulfilled demand to compensate for
          # that.
          existing_supply = related_parent_edges.map(&:demand).compact.sum
        end

        @edge.from.demand - existing_supply
      end

      # Internal: The "out" edges on the parent node, excluding the edge being
      # calculated.
      #
      # Returns an array of edges.
      def related_parent_edges
        @rpe ||= @edge.from.out_edges.to_a - [@edge]
      end

      # Internal: The "in" edges on the child node, excluding the edge being
      # calculated.
      #
      # Returns an array of edges.
      def related_child_edges
        @rce ||= @edge.to.in_edges.to_a - [@edge]
      end
    end # FromChildDemand
  end # EdgeDemand
end # Refinery::Strategies
