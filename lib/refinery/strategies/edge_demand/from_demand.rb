module Refinery::Strategies
  module EdgeDemand
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
          # We already know how the parent node supplies its other children?
          parental_siblings(edge).all?(&:demand) #&&
          # We already know how the child is supplied by its other parents?
          #child_siblings(edge).all?(&:demand)
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
          # child_siblings(edge).sum(&:demand)

        # if edge.from.key == :b && edge.to.key == :y
          # puts
          # puts ">>> #{ edge.inspect }"
          # puts "    " + ('-' * edge.inspect.length)
          # puts "    available_supply:   #{ available_supply.inspect }"
          # puts "      from_output:        #{ edge.from.output_of(edge.label).inspect }"
          # puts "      parental_sib_out:   #{ parental_siblings(edge).sum(&:demand).inspect }"
          # puts "    unfulfilled_demand: #{ unfulfilled_demand.inspect }"
          # puts "      edge_to_demand:     #{ edge.to.demand_for(edge.label).inspect }"
          # puts "      existing_supply:    #{ existing_supply.inspect }"
          # puts
        # end

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
