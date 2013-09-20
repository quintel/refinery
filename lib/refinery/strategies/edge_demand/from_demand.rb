module Refinery::Strategies
  module EdgeDemand
    # An advanced strategy which calculates the demand of an edge by looking
    # at the demand of the parent and child nodes.
    #
    # To calculate the demand of the edge, we need to know how much energy is
    # supplied by the parent node to each of its children. Since the parent
    # node may have multiple outgoing edges, we have to figure this out by
    # computing how much demand of its children is not supplied by
    # other nodes.
    #
    # Take the following example:
    #
    #      (10) [A]     [B] (75)   [C]
    #           / \     /          /
    #          /   \   / _________/
    #         /     \ / /
    #   (5) [X]     [Y] (100)
    #
    # Here we know the demand of four nodes, while one supplier, [C], remains
    # unknown. EdgeDemand::SingleParent will tell us that A->X carries 5
    # energy (to supply the demand from [X]).
    #
    # EdgeDemand::FromDemand will then be able to compute a value for A->Y
    # since it can determine that 5 energy from [A] remains unallocated. B->Y
    # is next since we can easily infer that it supplies all of its output to
    # [Y], and finally EdgeDemand::FromDemand will be able to determine a
    # value for C->Y by understanding that [Y] still requires a further 20
    # energy to meet its demand.
    class FromDemand
      include Reversible

      def calculable?(edge)
        # Parent and child demand?
        from(edge).demand && to(edge).demand &&
          # We already know how the parent supplies its other children?
          related_parent_edges(edge).all?(&:demand)
      end

      def calculate(edge)
        available   = available_supply(edge)
        unfulfilled = unfulfilled_demand(edge)

        available < unfulfilled ? available : unfulfilled
      end

      #######
      private
      #######

      # Internal: Calculates how much of the parent's energy supply is
      # available to this edge.
      #
      # This is the total amount of carrier energy output by the node, minus
      # that which is already allocated to other related edges.
      #
      # For example:
      #
      #       [A] (4)
      #   (2) / \
      #     [X] [Y]
      #
      # In this simple example where we want to calculate A->Y, [A] is
      # outputting 4 gas energy, of which 2 is already allocated to A->X.
      # Therefore available supply is 2.
      #
      # Returns a float.
      def available_supply(edge)
        from(edge).demand - related_parent_edges(edge).sum(&:demand)
      end

      # Internal: Calculates how much energy is needs to be supplied to the
      # child in order to meet its demand.
      #
      # This is the total amount of carrier energy demanded by the node, minus
      # that which is already supplied by related edges.
      #
      # For example:
      #
      #    [A]   [B]   [C]
      #      \   /_____/
      #   (2) \ //
      #       [X] (10)
      #
      # If we are calculating a value for B->X, we know that [X] demands 10
      # energy, and that 2 of that is already supplied by A->X. We don't know
      # how much energy is supplied by B->X or C->X, therefore 8 demand is
      # unfulfilled.
      #
      # Returns a float.
      def unfulfilled_demand(edge)
        existing_supply =
          if (rce = related_child_edges(edge)).any?
            # If the child element has other parents, and we already know
            # their demand, we will reduce the unfulfilled demand to
            # compensate for that.
            #
            # We do not need to explictly call "compact" on the result of the
            # map, since Turbine pipelines skip elements which are nil.
            rce.sum { |other| other.demand || Rational(0) }
          else
            0.0
          end

        to(edge).demand - existing_supply
      end

      # Internal: The "out" edges on the parent node, excluding the edge being
      # calculated.
      #
      # Returns an array of edges.
      def related_parent_edges(edge)
        out_edges(from(edge)).reject { |member| member == edge }
      end

      # Internal: The "in" edges on the child node, excluding the edge being
      # calculated.
      #
      # Returns an array of edges.
      def related_child_edges(edge)
        in_edges(to(edge)).reject { |member| member == edge }
      end
    end # FromDemand
  end # EdgeDemand
end # Refinery::Strategies
