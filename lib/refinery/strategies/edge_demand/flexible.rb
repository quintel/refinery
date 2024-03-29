module Refinery::Strategies
  module EdgeDemand
    # Provides a slot with whatever energy is still demanded, after all other
    # edges have been calulated. Unlike FillRemaining.reversed, Flexible will
    # defer calculation if the edge has a max_demand which is not yet known.
    class Flexible < FillRemaining.reversed
      # Public: Determines if the flexible edge can be calculated. In addition
      # to the normal FillRemaining checks, we assert that the supplier has a
      # max_demand defined if the edge is a flex-max edge.
      def calculable?(edge)
        # Don't handle reversed edges.
        return false if edge.get(:reversed)

        # Assert max demand is present for flex-max edges.
        return false if edge.get(:priority) && edge.from.max_demand.nil?

        super
      end

      # Public: Calculates the demand of the edge. Checks that the calculated
      # value does not exceed the max demand of the parent node.
      #
      # Returns a rational.
      def calculate(edge)
        calculated = super

        max_demand = edge.max_demand
        max_demand && max_demand < calculated ? max_demand : calculated
      end

      private

      # Internal: Given an edge, determines the demand of the child node (the
      # flexible strategy is used in child-to-parent mode only).
      #
      # This will preferentially return the node's +demand+ attribute if it
      # has one, otherwise it will see if all of the nodes out edges (minus
      # those with the "overflow" behaviour) have a known demand. This allows
      # it to act like ETEngine's "flexible" links.
      #
      # Returns a numeric, or nil if no demand can be determined.
      def parent_demand(edge)
        super || parent_demand_from_outputs(edge)
      end

      # Internal: Tries to determine the demand of the parent by looking at the
      # demand of its output edges. Ignores any edges which are overflow (since
      # their demand will not yet be set, butw will resolve to zero if this edge
      # has demand) and any which loop back to this edge's "from" node.
      def parent_demand_from_outputs(edge)
        Refinery::Util.strict_sum(edge.to.out_edges.select do |other|
          other.demand ||
            (other.get(:type) != :overflow || other.to == edge.from)
        end, &:demand)
      end

      # Internal: Given an incoming edge on the +to+ node, determines if the
      # edge contains enough information to allow us to use this strategy.
      #
      # Returns true or false.
      def calculable_sibling?(edge, sibling)
        super || (
          sibling.get(:type) == :flexible &&
          sibling.priority < edge.priority
        )
      end
    end
  end
end
