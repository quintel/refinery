module Refinery::Strategies
  module Demand
    # A strategy for calculating the demand of a node when we know the shares
    # of all the outgoing edges, and the demands of the child nodes.
    class FromChildren
      def self.calculable?(node)
        ! complete_slot(node).nil?
      end

      def self.calculate(node)
        slot = complete_slot(node)
        slot.edges.sum(&:demand) / slot.get(:share)
      end

      def self.complete_slot(node)
        node.slots.out.detect do |slot|
          slot.edges.any? && slot.edges.all?(&:demand)
        end
      end
    end # FromChildren
  end # Demand
end # Refinery::Strategies
