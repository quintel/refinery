module Refinery::Strategies
  module EdgeDemand
    class Flexible < FillRemaining.reversed
      # Public: Determines if the flexible edge can be calculated. In addition
      # to the normal FillRemaining checks, we assert that the supplier has a
      # max_demand defined if the edge is a flex-max edge.
      def calculable?(edge)
        super unless edge.get(:priority) && edge.from.max_demand.nil?
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

      #######
      private
      #######

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
        if edge.to.in_edges.one?
          edge.from.output_of(edge.label)
        else
          super(edge) ||
            Refinery::Util.strict_sum(edge.to.out_edges.select do |other|
              other.demand ||
                (other.get(:type) != :overflow || other.to == edge.from)
            end, &:demand)
        end
      end

      # Internal: Given an incoming edge on the +to+ node, determines if the
      # edge contains enough information to allow us to use this strategy.
      #
      # Returns true or false.
      def calculable_sibling?(edge, sibling)
        super || (
          sibling.get(:type) == :flexible &&
          sibling.priority < edge.priority )
      end
    end # Flexible
  end # EdgeDemand
end # Refinery::Strategies
