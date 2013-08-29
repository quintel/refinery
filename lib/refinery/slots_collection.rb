module Refinery
  # Provides a fluent API for reading slot data from a node. Assumes that the
  # slots have been set up first using the relevant catalysts.
  #
  #   node.slots.out
  #   # => [#<Slot>, #<Slot>, ...]
  #
  #   node.slots.in(:gas)
  #   # => #<Slot>
  class SlotsCollection
    include Enumerable

    # Public: The direction of the slots in the collection. +:in+ or +:out+.
    attr_reader :direction

    # Public: The Refinery::Node to which the collection belongs.
    attr_reader :node

    # Public: Creates a new collection for the given +node+ and +direction+.
    #
    # Returns a SlotsCollection.
    def initialize(node, direction)
      @node      = node
      @direction = direction
      @slots     = {}
    end

    # Public: Retrieves the slot with the matching +carrier+.
    #
    # Returns a Slot, or nil if no such slot exists in the collection.
    def get(carrier)
      @slots[carrier] ||
        raise(NoSuchCarrierError.new(@node, @direction, carrier))
    end

    # Public: Adds a new slot to the collection, using the given +carrier+.
    # Optionally provide +properties+ you want to be stored on the slot.
    #
    # Raises a SlotAlreadyExistsError if the collection already has a slot
    # with the same carrier.
    #
    # Returns the slot.
    def add(carrier, properties = {})
      if include?(carrier)
        raise SlotAlreadyExistsError.new(@node, @direction, carrier)
      end

      @slots[carrier] = Slot.new(@node, @direction, carrier, properties)
    end

    # Public: Determines if a slot which uses +carrier+ is already present in
    # the collection.
    #
    # Returns true or false.
    def include?(carrier)
      @slots.key?(carrier)
    end

    # Public: The slots within the collection.
    #
    # Returns an array of zero or more Slots.
    def to_a
      @slots.values
    end

    # Public: Returns how many slots are contained within the collection.
    #
    # Returns an integer.
    def length
      @slots.length
    end

    # Public: Returns whether the the collection has no slots.
    #
    # Returns true or false.
    def empty?
      length == 0
    end

    # Public: Required by Enumerable. Iterates through each slot in the
    # collection.
    #
    # Returns nothing.
    def each
      to_a.each { |slot| yield(slot) }
    end

    # Public: A human-readable version of the collection; useful for debuging.
    #
    # Returns a string.
    def inspect
      "#<SlotCollection (#{ @direction }) node=#{ @node.key } " \
        "carriers=[#{ to_a.map(&:carrier).sort.join(', ') }]>"
    end

    alias_method :to_s, :inspect
  end # SlotsCollection
end # Refinery
