module Refinery::Strategies
  module EdgeDemand
    # Overflow edges allow excess energy on a node to flow backwards, towards
    # a parent node. The overflow edge points in the opposite (anti-parallel)
    # direction to an ordinary edge.
    #
    # For example
    #
    #   ┌───┐
    #   │ A │
    #   └───┘
    #     |
    #     v
    #   ┌───┐ <─ ┌───┐
    #   | B |    │ X │
    #   └───┘ ─> └───┘
    #     |        |
    #     v        v
    #   ┌───┐    ┌───┐
    #   | C |    │ Y │
    #   └───┘    └───┘
    #
    # Here, the overflow edge is from [B] to [X]. If [C] demands less energy
    # than [B] supplies, then the excess will flow along the overflow edge an
    # into [X]. In "normal" circumstances, however, energy will flow from both
    # [A] and [X] in to [B], and the overflow edge will have a demand of 0.
    class Overflow
      def calculable?(edge)
        edge.get(:type) == :overflow &&
          unrelated_demand(edge) &&
          unrelated_supply(edge)
      end

      def calculate(edge)
        # If the anti-parallel edge already has demand assigned, then the
        # overflow edge *must not* carry any energy.
        anti = anti_parallel_edge(edge)

        return 0.0 if anti && anti.demand && ! anti.demand.zero?

        # If the slot has a share, we need to respect that, otherwise we
        # assume that that share will be calculated later (hence || 1)
        slot_share  = edge.from.slots.out(edge.label).share || Rational(1)

        node_supply = unrelated_supply(edge) * slot_share
        node_demand = unrelated_demand(edge)

        if node_supply > node_demand
          # If the node has more energy than it's children demand, then the
          # excess energy *must* overflow through this edge.
          node_supply - node_demand
        elsif node_demand.zero?
          node_supply
        else
          # If there is no excess energy (it is either balanced, or the node
          # still needs more), then the overflow must be zero.
          0.0
        end
      end

      # Public: A human-readable version of the strategy.
      #
      # Returns a string.
      def inspect
        "#<#{ self }>"
      end

      # Public: The strategy as a string.
      #
      # Returns a string.
      def to_s
        self.class.name
      end

      private

      # Internal: Given an overflow edge, creates an array of edges on the
      # "from" node which supply energy, *except* for the anti-parallel edge
      # whose demand is likely to be unknown.
      #
      # Returns an array of edges.
      def unrelated_supply(edge)
        if (suppliers = edge.from.in_edges.to_a).length.zero?
          # The from node has no in edges; it is a primary supplier.
          edge.from.demand
        else
          Refinery::Util.strict_sum(suppliers.reject do |other|
            other.from == edge.to ||
            (!other.demand &&
              other.get(:type) == :flexible &&
              !other.get(:reversed))
          end, &:demand)
        end
      end

      # Internal: Given an overflow edge, creates an array of edges on the
      # "from" node which take energy away, excluding the overflow edge.
      #
      # Returns an array of edges.
      def unrelated_demand(edge)
        no_loop = edge.from.in_edges.none? do |other|
          other.from == edge.to
        end

        if edge.from.out_edges.one? && no_loop
          Rational(0)
        else
          Refinery::Util.strict_sum(
            edge.from.out_edges.select { |o| o != edge }, &:demand)
        end
      end

      # Overflow edges are accompanied by a normal edge going in the opposite
      # ("anti-parallel") direction.
      #
      # Returns an edge.
      def anti_parallel_edge(edge)
        edge.to.out_edges.to_a.detect { |o| o.to == edge.from }
      end
    end
  end # EdgeDemand
end # Refinery::Strategies
