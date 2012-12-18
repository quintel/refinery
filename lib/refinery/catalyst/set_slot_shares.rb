module Refinery
  module Catalyst
    # Internal: Sets the share of all slots to 1.0, except when a share has
    # already been set.
    #
    # This relies on the (probably slightly incorrect) assumption that we
    # should know the share of each slot ahead-of-time (perhaps manually
    # chosen by a modeller). For the current stub graphs, setting each slot
    # to 1.0 is sufficient.
    #
    # As a fail-safe, if any node has more than one type of slot in a
    # direction (:in or :out), a TooManySlots error is raised. This error is
    # not raised if each of the slots already have a "share" set.
    module SetSlotShares
      # Public: Assigns a share value to each slot.
      #
      # Returns nothing.
      def self.call(graph)
        graph.nodes.each do |node|
          assign_shares_for(node, :in)
          assign_shares_for(node, :out)
        end
      end

      # Internal: Given a node and direction, assigns a share to each slot in
      # that direction.
      #
      # Returns nothing.
      def self.assign_shares_for(node, direction)
        slots = node.get(:slots)[direction].values

        if slots.length > 1 && slots.any? { |slot| slot.get(:share).nil? }
          raise TooManySlotsError.new(node, direction)
        elsif slots.one? && slots.first.get(:share).nil?
          slots.first.set(:share, 1.0)
        end
      end

      private_class_method :assign_shares_for
    end # SetSlotShares
  end # Catalyst
end # Refinery
