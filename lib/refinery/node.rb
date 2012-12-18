module Refinery
  class Node < Turbine::Node
    # Public: The demand calculator for this node.
    #
    # Returns a NodeDemandCalculator.
    def calculator
      @calculator ||= Demand::NodeDemandCalculator.new(self)
    end

    # Public: The demand assigned to the node.
    #
    # Returns a float, or nil if no demand is yet assigned.
    def demand
      get(calculator.demand_attribute)
    end

    # Public: Provides a fluent API for accessing the slots on the node.
    #
    # For example
    #
    #   node.slots.out
    #   # => [#<Slot>, #<Slot>, ...]
    #
    #   node.slots.in(:gas)
    #   # => #<Slot>
    #
    # Returns a SlotsProxy.
    def slots
      @slots ||= SlotsProxy.new(self)
    end

    # Public: Connects this node to another.
    #
    # Overwrites Turbine#connect_to to automatically use the Refinery Edge
    # class instead.
    #
    # target     - The node to which you want to connect. The +target+ node
    #              will be the "from" end of the edge.
    # label      - An optional label describing the relationship between the
    #              two nodes.
    # properties - Optional key/value properties to be associated with the
    #              edge.
    #
    # Example:
    #
    #   phil = Turbine::Node.new(:phil)
    #   luke = Turbine::Node.new(:luke)
    #
    #   phil.connect_to(luke, :child)
    #
    # Returns the Edge which was created.
    #
    # Raises a Turbine::DuplicateEdgeError if the Edge already existed.
    def connect_to(target, label = nil, properties = nil)
      Edge.new(self, target, label, properties).tap do |edge|
        self.connect_via(edge)
        target.connect_via(edge)
      end
    end
  end # Node
end # Refinery
