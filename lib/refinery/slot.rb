module Refinery
  # Contains all outgoing or incoming edges on a node which have the same
  # carrier. Each node has separate "incoming" and "outgoing" slots.
  class Slot
    include Turbine::Properties

    # Public: The node to which the slot belongs.
    attr_reader :node

    # Public: The edges aggregated by the node.
    attr_reader :edges

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
      @edges     = node.edges(direction, carrier)
      @direction = direction
      @carrier   = carrier

      self.properties = properties
    end

    # Public: The sum of all demand supplied through the edges in the slot.
    #
    # Returns a float, or nil if one or more of the edges do not yet have
    # enough data to calculate their demand.
    def demand
      demands = @edges.map { |edge| edge.get(:calculator).demand }
      (demands.all? && demands.sum) || nil
    end
  end # Slot
end # Refinery
