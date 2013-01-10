module Refinery::Strategies
  module Demand
    # FillRemaining is a strategy for calculating demand which looks at a
    # node's children in order to determine how much demand is unaccounted
    # for, and assigns that demand to the node. For example:
    #
    #   (50) [A] [B] (20)
    #          \ /
    #          [X]
    #
    # In this case, it's quite clear that X needs to have a demand of 70 in
    # order to satisfy the needs of it's children. Simple cases like this
    # would be handled by the FromParents strategy.
    #
    # More complicated cases can arise when the node has siblings, since we
    # can't simply assign all of the parent demand to the child, but must
    # instead account for the demand of those siblings also.
    #
    #       (50) [A]     [B] (20)
    #            / \     / \
    #     (1.0) /   \   /   \ (1.0)
    #          /     \ /     \
    #   (20) [X]     [Y]     [Z] (5)
    #
    # Here we can determine that A supplies Y with 30 (since 20 of its output
    # goes to X) and B supplies 15. Therefore Y has a demand of 45.
    class FillRemaining
      def self.calculable?(node)
        return false unless node.in.any?
        return false unless parents_have_demand?(node)

        node.in.out_edges.reject { |edge| edge.to == node }.all?(&:demand)
      end

      def self.calculate(node)
        node.in.uniq.sum { |child| remaining_demand(node, child) }
      end

      # Internal: Given a +child+ node, sums the demand supplied by edges not
      # connected to the +parent+, and tells us how much demand the parent
      # needs to supply in order to fulfil demand.
      #
      # Returns a float.
      def self.remaining_demand(parent, child)
        related_edges = child.out_edges.reject { |edge| edge.to == parent }

        child.demand - related_edges.map(&:demand).sum
      end

      # Internal: Asserts that all of the node's parents have demand defined.
      #
      # Returns true or false.
      def self.parents_have_demand?(node)
        node.in.all?(&:demand)
      end
    end # FillRemaining
  end # Demand
end # Refinery::Strategies
