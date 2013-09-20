module Refinery::Strategies
  module EdgeDemand
    # A strategy for calculating the demand of an edge, when we know the
    # demands of all the other edges which leave the parent.
    #
    # This is a specialisation of the FillRemaining strategy, which allows us
    # to calculate the demand of a single edge even if we don't know the share
    # of the slot.
    #
    # ... we know that B->X has a demand of 5, therefore A->X must have a
    # demand of 20 (so that that all edges meet the demand of [X]).
    #
    # For example:
    #
    #                  [A] (20)
    #    :electricity  / \ (5) :gas
    #                [X] [Y]
    #
    # ... we know that A->Y has a demand of 5, and the parent node demand is
    # 20, therefore A->X must have a demand of 15.
    class FillRemainingAcrossSlots
      include Reversible

      def calculable?(edge)
        parent_demand(edge) &&
          out_edges(from(edge)).all? do |other|
            other == edge || other.demand
          end
      end

      def calculate(edge)
        demand = parent_demand(edge)
        supply = out_edges(from(edge)).get(:demand).to_a.compact.sum

        if demand >= supply
          demand - supply
        else
          # This should only occur when the strategy is being calculated in
          # reverse (from child-to-parent), and it is assumed that there is
          # an overflow edge which will take away the excess.
          0.0
        end
      end

      #######
      private
      #######

      # Internal: Given an edge, determines the demand of the parent node.
      #
      # Returns a numeric, or nil if no demand can be determined.
      def parent_demand(edge)
        from(edge).demand
      end
    end # FillRemainingAcrossSlots
  end # EdgeDemand
end # Refinery::Strategies
