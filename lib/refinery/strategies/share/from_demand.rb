module Refinery::Strategies
  module Share
    # A strategy for calculating the share of an edge by looking at the demand
    # of the parent and child nodes.
    #
    # To calculate the share of the edge, we need to know how much energy is
    # supplied by the node to each of its children. Since the parent node may
    # have multiple outgoing edges with shares, we have to figure this out by
    # computing how much demand of its children is not supplied by other
    # nodes.
    #
    # Take the following example:
    #
    #              (100)
    #   (5) [R]     [M]     [F] (100)
    #         \     / \     /
    #    (1.0) \   /   \   / (1.0)
    #           \ /     \ /
    #      (80) [S]     [C] (125)
    #
    # Here we know the demand of all five nodes, and the share of two edges
    # which supply demand to the children. This means we can figure out how
    # much energy [S] and [C] demand which is *not* provided by [R] or [F].
    # We cannot, however, calculate the two unknown edge shares if the parent
    # node [M] has *any* children whose other parents ([R] and [F] in this
    # example) don't already have demand defined.
    class FromDemand
      def self.calculable?(edge)
        # Parent and child demand?
        edge.from.demand && edge.to.demand &&
          # Siblings supply from other parents is already known?
          siblings(edge).all?(&:demand)
      end

      def self.calculate(edge)
        # Figure out the total amount of demand assigned to the parent's
        # children which hasn't yet been accounted for (and therefore must be
        # supplied by the parent).
        sibling_supply = siblings(edge).sum(&:demand)

        (edge.to.demand - sibling_supply) / edge.from.demand
      end

      # Internal: The "in" edges on the "to" node, excluding the given +edge+.
      #
      # edge - The edge whose siblings are to be retrieved.
      #
      # Returns an array of edges.
      def self.siblings(edge)
        edge.to.in_edges.to_a - [edge]
      end
    end # FromDemand
  end # Share
end # Refinery::Strategies
