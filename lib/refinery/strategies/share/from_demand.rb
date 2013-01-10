module Refinery::Strategies
  module Share
    # A strategy for calculating the share of an edge by looking at the demand
    # of the parent and child nodes.
    #
    # To calculate the share of the edge, we need to know how much energy is
    # supplied by the parent node to each of the children. Since the parent
    # node may have multiple outgoing edges with shares, we have to figure
    # this out by computing how much demand of its children is not supplied by
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
    # Here we know the demand of four nodes, while one parent [C] remains
    # unknown. Share::Solo will tell us that A->X carries 5 energy (to supply
    # the demand from [X]). Share::FillDemand will then be able to compute
    # values for A->X, B->Y, and finally Share::FromDemand will be able to
    # determine a value for C->Y.
    class FromDemand
      def self.calculable?(edge)
        # Parent and child demand?
        edge.to.demand && edge.from.demand &&
          # Siblings supply from other parents is already known?
          siblings(edge).all?(&:demand)
      end

      def self.calculate(edge)
        # Figure out the total amount of demand assigned to the parent's
        # children which hasn't yet been accounted for (and therefore must be
        # supplied by the parent).
        sibling_supply = siblings(edge).sum(&:demand)

        (edge.from.demand - sibling_supply) /
          (edge.to.demand * edge.to.slots.in(edge.label).get(:share))
      end

      # Internal: The "in" edges on the "to" node, excluding the given +edge+.
      #
      # edge - The edge whose siblings are to be retrieved.
      #
      # Returns an array of edges.
      def self.siblings(edge)
        edge.from.out_edges.to_a - [edge]
      end
    end # FromDemand
  end # Share
end # Refinery::Strategies
