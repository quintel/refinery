module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculating the demand of an edge, when we already know
    # the demands of the other edges which use the same carrier, on the parent
    # node.
    #
    # A strategy for calculating edge demand when we already know the demand
    # of all the other outbound of the same carrier on the parent node.
    #
    # For example:
    #
    #      [A] (20)
    #      / \ (5)
    #    [X] [Y]
    #
    # ... we know that A->Y has a demand of 5, and the parent node demand is
    # 20, therefore A->X must have a demand of 15.
    class FillRemaining
      include Reversible

      def calculable?(edge)
        parent_demand(edge) &&
          parent_slot_share(edge) &&
          siblings(edge).all? { |other| calculable_sibling?(edge, other) }
      end

      def calculate(edge)
        demand = parent_demand(edge) * parent_slot_share(edge)
        supply = siblings(edge).get(:demand).to_a.compact.sum

        if demand >= supply
          demand - supply
        else
          # This should only occur when the strategy is being calculated in
          # reverse (from child-to-parent), and it is assumed that there is
          # an overflow edge which will take away the excess.
          0.0
        end
      end

      private

      # Internal: Given an edge, determines the demand of the parent node.
      #
      # Returns a numeric, or nil if no demand can be determined.
      def parent_demand(edge)
        from(edge).demand
      end

      # Internal: Given the edge to be calculated, and one of its siblings
      # (another outgoing edge from the parent), determines if the edge
      # provides enough information to use this strategy.
      #
      # Returns true or false.
      def calculable_sibling?(edge, sibling)
        sibling == edge || sibling.demand
      end

      # Internal: The share of the slot to which the edge belongs. Is
      # overridden in "...AcrossSlots" to make the strategy work without the
      # need for a conversion.
      #
      # Returns a numeric, or nil if no share is available.
      def parent_slot_share(edge)
        parent_slot(edge).share
      end

      # Internal: The other edges belonging to the node which are expected to
      # already have a demand.
      #
      # Returns the edges.
      def siblings(edge)
        out_edges(from(edge), edge.label)
      end
    end # FillRemaining
  end # EdgeDemand
end # Refinery::Strategies
