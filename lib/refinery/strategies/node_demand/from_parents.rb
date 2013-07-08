module Refinery::Strategies
  module NodeDemand
    # A strategy for calculating the demand of a node when we know the demand
    # of all its parents, and the shares of all incoming edges.
    class FromParents
      def self.calculable?(node)
        ! complete_slot(node).nil?
      end

      def self.calculate(node)
        slot = complete_slot(node)
        slot.edges.sum(&:demand) / slot.share
      end

      def self.complete_slot(node)
        node.slots.in.detect do |slot|
          slot.share && slot.edges.any? && slot.edges.all?(&:demand)
        end
      end
    end # FromParents
  end # NodeDemand
end # Refinery::Strategies
