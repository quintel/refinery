module Refinery
  # Contains all outgoing or incoming edges on a node which have the same
  # carrier. Each node has separate "incoming" and "outgoing" slots.
  class Slot
    include Turbine::Properties
    include PreciseProperties

    # Public: The node to which the slot belongs.
    attr_reader :node

    # Public: The edges aggregated by the node.
    attr_reader :edges

    # Shares should be cast to Rational.
    precise_property :share

    # Public: The direction of the slot indicates which "side" of the node is
    # represented. Each node has separate "in" and "out" slots, representing
    # edges which are entering and leaving the node respectively.
    #
    # If the edges within the slot are incoming edges on the node, the
    # direction will be :in, otherwise it is :out.
    attr_reader :direction

    # Public: What type of energy flows through the links? e.g. :gas, :heat.
    attr_reader :carrier

    # Public: Creates a new Slot for a given +node+ and +edges+.
    #
    # node       - The node to which the slot belongs.
    # direction  - The direction of the edges which are used by the slot. :in
    #              or :out.
    # carrier    - The carrier -- or energy type -- emitted or received by the
    #              carrier. For example, :gas, :electricity, etc. This is used
    #              to match the label on the node's edges.
    # properties - Optional key/value properties to be associated with the
    #              slot.
    #
    # Returns the slot.
    def initialize(node, direction, carrier, properties = {})
      @node      = node
      @direction = direction
      @carrier   = carrier

      self.properties = properties
    end

    # Public: The edges which are aggregated by the slot. Cached after the
    # first call.
    #
    # Returns an array of Edges.
    def edges
      @edges ||= node.edges(direction, carrier).dup.freeze
    end

    # Public: The share of the slot.
    #
    # If a share has been explicitly set, it will always be the value
    # returned. Otherwise, the slot will attempt to figure out the share for
    # itself:
    #
    #   * If the node has a single carrier in the direction (in or out), then
    #     the share returned will be 1.0.
    #
    #   * If the demand of the slot is known, and the either the demand of
    #     the node, *or* all of the other slots, is known, then the share is
    #     calculated.
    #
    #   * Otherwise, the share cannot be determined automatically.
    #
    # Returns a Rational or nil.
    def share
      if (explicit = get(:share)) then return explicit end

      slots = @node.slots.public_send(@direction)

      if slots.one?
        set(:share, 1)
      elsif get(:type) == :elastic
        others = slots.reject do |slot|
          slot == self || slot.get(:type) == :elastic
        end

        if others.all?(&:share)
          set(:share, 1 - others.sum(&:share))
        end
      elsif demand
        node_demand = @node.demand ||
          slots.all?(&:demand) && slots.sum(&:demand)

        if node_demand && ! node_demand.zero?
          set(:share, demand / node_demand)
        end
      end
    end

    # Public: The sum of all demand supplied through the edges in the slot.
    #
    # Note that calling Slot#demand is subtly different from calling
    # Node#demand_for or Node#demand_from in that it asserts that all of the
    # links aggregated in the slot have a demand figure, and then sums those
    # demands to arrive at the result.
    #
    # Node#demand_for and Node#demand_from take the demand assigned to the
    # Node, and convert it using the slot "share". Effectively, the node
    # methods tell you what demand *should* be, and Slot#demand tells you what
    # the demand of the links *actually are*. If the calculations were
    # successful, both numbers should be identical.
    #
    # Returns a float, or nil if one or more of the edges do not yet have
    # enough data to calculate their demand.
    def demand
      demands = edges.map(&:demand)
      (demands.all? && demands.sum) || nil
    end

    def inspect
      "#<#{ self.class.name } (#{ @direction }, #{ @carrier }) " \
        "node=#{ @node.key.inspect }>"
    end
  end # Slot
end # Refinery
