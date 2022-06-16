module Refinery::Strategies
  module NodeDemand
    # Calculates the demand of a node when we know the demand of all of the
    # edges for one slot, and the share of the slot, but not the shares of the
    # edges.
    class FromCompleteSlot
      include Reversible

      def calculable?(node)
        completed_slot(node)
      end

      def calculate(node)
        slot = completed_slot(node)
        slot.edges.sum(&:demand) / slot.share
      end

      private

      # Internal: Finds the first slot with a share whose edges all have a
      # demand available.
      #
      # Returns a slot or nil.
      def completed_slot(node)
        in_slots(node).detect do |slot|
          slot.share && ! slot.share.zero? &&
            slot.edges.any? && slot.edges.all?(&:demand)
        end
      end
    end
  end
end
