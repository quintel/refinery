module Refinery::Strategies
  module Demand
    # Fill remaining is a calculation strategy which looks at a nodes children
    # in order to determine how much demand remains to be accounted for, and
    # assigns that demand to the node. For example:
    #
    #            A
    #           / \
    #    (50) [B] [C] (20)
    #
    # In this case, it is quite clear that A needs to have a demand of 70 in
    # order to satisfy the needs of it's children. It will also work if the
    # child nodes have other parents, so long as those parents have a demand
    # already calculated, and the edges connecting them have a share:
    #
    #   (20) [Y]     [A]     [Z] (5)
    #          \     / \     /
    #     (1.0) \   /   \   / (1.0)
    #            \ /     \ /
    #       (50) [B]     [C] (20)
    #
    class FillRemaining
      def self.calculable?(node)
        return false unless node.out.any?
        return false unless children_have_demand?(node)

        node.out.in_edges.reject { |edge| edge.from == node }.all?(&:demand)
      end

      def self.calculate(node)
        node.out.uniq.sum { |child| remaining_demand(node, child) }
      end

      # Internal: Given a +child+ node, sums the demand supplied by edges not
      # connected to the node (+parent+) being calculated, and tells us how
      # much demand the parent needs to supply.
      #
      # Returns a float.
      def self.remaining_demand(parent, child)
        related_edges = child.in_edges.reject { |edge| edge.from == parent }

        child.demand - related_edges.map(&:demand).sum
      end

      # Internal: Asserts that all of the node's children have demand defined.
      #
      # Returns true or false.
      def self.children_have_demand?(node)
        node.out.all?(&:demand)
      end
    end # FillRemaining
  end # Demand
end # Refinery::Strategies
