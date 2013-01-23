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
      def self.calculable?(edge)
        # Parent and child demand?
        edge.to.demand && edge.from.demand &&
          # We already know how the parent node supplies its other children?
          parental_siblings(edge).all?(&:demand)
      end

      def self.calculate(edge)
        available_supply =
          # Output of the parent for the edge's carrier.
          edge.from.output_of(edge.label) -
          # Minus energy already being supplied to the parent's other
          # children.
          parental_siblings(edge).sum(&:demand)

        if child_siblings = child_siblings(edge)
          # If the child element has other parents, and we already know their
          # demand, we will reduce the output of this link to compensate for
          # that.
          existing_supply =
            if child_siblings.all?(&:demand)
              child_siblings.sum(&:demand)
            else
              0.0
            end
        else
          existing_supply = 0.0
        end

        unfulfilled_demand =
          # Demand from the child for the edge's carrier.
          edge.to.demand_for(edge.label) -
          # Minus energy already supplied by other parents to the child.
          existing_supply

        if available_supply < unfulfilled_demand
          available_supply
        else
          unfulfilled_demand
        end
      end

      # Internal: The "in" edges on the "to" node, excluding the given +edge+.
      #
      # edge - The edge whose siblings are to be retrieved.
      #
      # Returns an array of edges.
      def self.parental_siblings(edge)
        edge.from.out_edges(edge.label).to_a - [edge]
      end

      def self.child_siblings(edge)
        edge.to.in_edges(edge.label).to_a - [edge]
      end
    end # FromDemand
  end # EdgeDemand
end # Refinery::Strategies
