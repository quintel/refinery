module Refinery::Strategies
  module NodeDemand
    # Given a node, attempts to determine the demand of the node by looking at
    # it's edges.
    #
    # * If all of the edges for one slot have a demand value, and
    #   we also know the share of the slot, we can calculate the demand.
    #
    # * In some cases we cannot determine the share of the slot because al
    #   the edges have zero demand. If *all* of the nodes edges have no demand
    #   then we can also say the node has no demand.
    #
    # FromEdges takes a single argument, +:in+ or +:out+ to configure in which
    # direction to look (in slots and edges, or out slots and edges).
    class FromEdges
      # Public: Creates a FromEdges strategy. Specify the +direction+ of the
      # slots and edges you want to use.
      def initialize(direction)
        @direction = direction.to_sym
      end

      def calculable?(node)
        completed_slot(node) || zero_demand?(node)
      end

      def calculate(node)
        if slot = completed_slot(node)
          slot.edges.sum(&:demand) / slot.share
        else
          0.0
        end
      end

      #######
      private
      #######

      # Internal: Finds the first slot with a share whose edges all have a
      # demand available.
      #
      # Returns a slot or nil.
      def completed_slot(node)
        slots(node).detect do |slot|
          slot.share && ! slot.share.zero? &&
            slot.edges.any? && slot.edges.all?(&:demand)
        end
      end

      def zero_demand?(node)
        edges = edges(node)

        edges.any? && edges.get(:demand).all? do |demand|
          demand && demand.zero?
        end
      end

      def slots(node)
        @direction == :in ? node.slots.in : node.slots.out
      end

      def edges(node)
        @direction == :in ? node.in_edges : node.out_edges
      end
    end # FromEdges
  end # NodeDemand
end # Refinery::Strategies
