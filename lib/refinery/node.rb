module Refinery
  class Node < Turbine::Node
    include PreciseProperties

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

    # Demand calculations need to be exact.
    precise_property :demand

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
      get(:demand)
    end

    # Public: The demand of the node for a given +carrier+.
    #
    # If the node demands a total of 200 energy, and its incoming gas slot has
    # a share of 0.25 (25% of all energy input), then the demand for gas is
    # 50.0.
    #
    # Raises NoSuchSlotError if the node has no inward slot for the carrier.
    #
    # Returns a float or nil if the node does not have a demand value set.
    def demand_for(carrier)
      slot = slots.in(carrier)
      demand * slot.share if demand && slot.share
    end

    # Public: The energy output of the node for a given +carrier+.
    #
    # If the node demands a total of 200 energy, and its outgoing gas slot has
    # a share of 0.25 (25% of all energy leaving the node), then the output of
    # gas is 50.0.
    #
    # Raises NoSuchSlotError if the node has no outward slot for the carrier.
    #
    # Returns a float or nil if the node does not have a demand value set.
    def output_of(carrier)
      slot = slots.out(carrier)
      demand * slot.share if demand && slot.share
    end

    # Public: The maximum permitted demand of the node. Used only in the
    # presence of a flex-max edge (a flexible edge with a priority).
    #
    # If no max demand is set on this node, it traverses to parent nodes
    # through incoming edges to figure it out.
    #
    # Returns a rational, or nil if no max demand is available.
    def max_demand
      get(:max_demand)
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
