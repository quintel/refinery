module Refinery
  # Provides a fluent API for reading slot data from a node. Assumes that the
  # slots have been set up first using the relevant catalysts.
  #
  #   node.slots.out
  #   # => [#<Slot>, #<Slot>, ...]
  #
  #   node.slots.in(:gas)
  #   # => #<Slot>
  class SlotsProxy
    # Public: Creates a new slots proxy.
    #
    # node - The node whose slots are to be made available.
    #
    # Returns a SlotsProxy
    def initialize(node)
      @node = node
    end

    # Public: The nodes in slots.
    #
    # carrier - An optional carrier; if you supply one, only the inbound slot
    #           matching this carrier will be returned. If no matching slot
    #           exists, nil will be returned.
    #
    # Returns an array of slots, or a single slot when supplying a carrier.
    def in(carrier = nil)
      slots_for(:in, carrier)
    end

    # Public: The nodes out slots.
    #
    # carrier - An optional carrier; if you supply one, only the outbound slot
    #           matching this carrier will be returned. If no matching slot
    #           exists, nil will be returned.
    #
    # Returns an array of slots, or a single slot when supplying a carrier.
    def out(carrier = nil)
      slots_for(:out, carrier)
    end

    #######
    private
    #######

    def slots_for(direction, carrier = nil)
      slots = @node.get(:slots)[direction]
      carrier ? slots[carrier] : slots.values
    end
  end # SlotsProxy
end # Refinery
