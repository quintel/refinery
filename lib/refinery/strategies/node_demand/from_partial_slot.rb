module Refinery::Strategies
  module NodeDemand
    # A demand calculation strategy which can determine the demand of a node
    # when it has two or more edges, and we know the demands *or shares* of
    # all of them.
    #
    # See: https://github.com/quintel/refinery/issues/32
    class FromPartialSlot
      include Reversible

      def calculable?(node)
        partial_slot(node)
      end

      def calculate(node)
        slot = partial_slot(node)

        known_demand = slot.edges.sum do |edge|
          edge.demand || Rational(0)
        end

        known_share  = slot.edges.sum do |edge|
          (! edge.demand && child_share(edge)) || Rational(0)
        end

        (known_demand / (1 - known_share)) / slot.share
      end

      #######
      private
      #######

      # Internal: Finds the first slot with a share whose edges all have a
      # demand available.
      #
      # Returns a slot or nil.
      def partial_slot(node)
        in_slots(node).detect do |slot|
          slot.share && ! slot.share.zero? &&
            slot.edges.all? { |edge| edge.demand || child_share(edge) } &&
            # We don't need to explicitly test that there are two or more
            # edges since an edge with a demand and share will be calculated
            # by the earlier FromCompleteEdge.
            slot.edges.count(&:demand) > 0 &&
            slot.edges.sum { |edge| edge.demand || Rational(0) } > 0 &&
            slot.edges.count { |edge| child_share(edge) } > 0
        end
      end
    end # FromPartialSlot
  end # NodeDemand
end # Refinery::Strategies
