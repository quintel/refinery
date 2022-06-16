module Refinery
  # Customises Turbine's Node class to provide methods useful for calculating
  # the Refinery graph.
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
    # force_recurse - Used internally to recursively determine the maximum
    #                 demand of the node by traversing the incoming edges until
    #                 we reach nodes which have an explicit max_demand.
    #
    # Returns a rational, or nil if no max demand is available.
    def max_demand(force_recurse = false)
      max_demand = get(:max_demand)

      if (! max_demand && force_recurse) ||
          max_demand == :recursive || max_demand == 'recursive'.freeze
        set(:max_demand, Refinery::Util.strict_sum(in_edges) do |edge|
          edge.max_demand(true)
        end)
      else
        max_demand
      end
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
        SlotCollection.new(self, :in),
        SlotCollection.new(self, :out)
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
        connect_via(edge)
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
  end
end
