module Refinery
  class Node < Turbine::Node
    # Internal: Used in Node#slots to provide a nice API for accessing slots.
    SlotsFacade = Struct.new(:in_collection, :out_collection) do
      # Public: Returns the nodes incoming slots. If a +carrier+ is supplied
      # only that slot is returned.
      def in(carrier = nil)
        carrier ? in_collection.get(carrier) : in_collection
      end

      # Public: Returns the nodes outgoing slots. If a +carrier+ is supplied
      # only that slot is returned.
      def out(carrier = nil)
        carrier ? out_collection.get(carrier) : out_collection
      end
    end

    # Public: The demand calculator for this node.
    #
    # Returns a Calculators::NodeDemand.
    def calculator
      @calculator ||= Calculators::NodeDemand.new(self)
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
    # Returns a SlotsFacade.
    def slots
      @slots ||= SlotsFacade.new(
        SlotsCollection.new(self, :in),
        SlotsCollection.new(self, :out)
      )
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
    # Returns the Edge which was created.
    #
    # Raises a Turbine::DuplicateEdgeError if the Edge already existed.
    def connect_to(target, label = nil, properties = nil)
      Edge.new(self, target, label, properties).tap do |edge|
        self.connect_via(edge)
        target.connect_via(edge)
      end
    end

    # Internal: Given an Edge, established the connection for this node.
    # Overwrites Turbine#connect_via to also set up the relevant slots.
    #
    # See Turbine#connect_via
    #
    # Returns the given edge.
    def connect_via(edge)
      if edge.to == self && ! slots.in.include?(edge.label)
        slots.in.add(edge.label)
      end

      if edge.from == self && ! slots.out.include?(edge.label)
        slots.out.add(edge.label)
      end

      super
    end
  end # Node
end # Refinery
