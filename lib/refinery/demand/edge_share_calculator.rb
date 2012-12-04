module Refinery
  module Demand
    class EdgeShareCalculator < Calculator
      # Public: Determines if the edge share can be calculated.
      #
      # Returns true or false.
      def calculable?
        not strategy.nil?
      end

      # Public: Sets the share value on the edge.
      #
      # Returns nothing.
      def calculate!
        case strategy
        when :only_edge
          @model.set(:share, 1.0)
        when :fill_remaining
          @model.set(:share, 1.0 -
            sum(@model.from.out_edges) { |edge| edge.get(:share) || 0.0 })
        when :infer_from_child_node
          others = sum(@model.from.out.uniq) do |node|
            node.get(:calculator).demand
          end

          @model.set(:share, @model.to.get(:calculator).demand / others)
        end

        super
      end

      # Public: Return if this calculator has already set a value.
      #
      # Returns true or false.
      def calculated?
        super || @model.get(:share)
      end

      #######
      private
      #######

      # Internal: Which strategy should be used to calculate the edge share.
      #
      # Depending on the state of "nearby" elements (related nodes and edges)
      # there are different ways to compute the share of the edge.
      #
      # Returns the strategy name as a symbol, or nil if there is no way to
      # currently calculate the value.
      def strategy
        if @model.from.out_edges.take(2).one?
          # The share can be set to 1.0 if this is the node's only out edge.
          :only_edge
        elsif fill_remaining?
          :fill_remaining
        elsif infer_from_child_node?
          :infer_from_child_node
        end
      end

      # Internal: Determines if it is possible to infer the share of the edge
      # by looking at the demand of the two connected nodes.
      #
      # For example, assume that all four nodes have a demand defined:
      #
      #      A
      #    / | \
      #   B  C  D
      #
      # We can therefore infer the share of each of A's out edges by
      # figuring out what proportion of demand is assigned to each out
      # node. This gets more complicated if one of the out nodes has a
      # second parent; we don't yet handle this.
      #
      # Returns true or false.
      def infer_from_child_node?
        # The child node and it's siblings required demand set...
        @model.from.out.get(:calculator).all?(&:demand) &&
          # The child nodes must each only take demand from the parent.
          @model.from.out.in_edges.all? { |edge| edge.from == @model.from }
      end

      # Internal: Determines if we can figure out the share by filling up
      # whatever is left. This is possible if all the other edges have a share
      # set, in which case the model can be set to +1.0 - others+.
      #
      # Returns true or false.
      def fill_remaining?
        @model.from.out_edges.all? do |edge|
          edge.similar?(@model) || edge.get(:share)
        end
      end

      # Internal: Given an enumerable, and a block, sums the values returned
      # by running the block on each element.
      #
      # enum - The items through which to iterate.
      #
      # Returns a float.
      def sum(enum)
        enum.inject(0.0) { |sum, element| sum + yield(element) }
      end
    end # EdgeShareCalculator
  end # Demand
end # Refinery
