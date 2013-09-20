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
    class FillRemainingAcrossSlots < FillRemaining
      #######
      private
      #######

      def siblings(edge)
        out_edges(from(edge))
      end

      def parent_slot_share(*)
        1.0
      end
    end # FillRemainingAcrossSlots
  end # EdgeDemand
end # Refinery::Strategies
