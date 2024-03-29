module Refinery
  # Customises Turbine's Edge class to provide methods useful for calculating
  # the Refinery graph.
  class Edge < Turbine::Edge
    include PreciseProperties

    # Calculated demands, and shares both need to have arbitrary precision.
    precise_property :demand, :child_share, :parent_share

    # Public: The share calculator for the edge.
    #
    # Returns an Calculators::EdgeDemand.
    def calculator
      @calculator ||= Calculators::EdgeDemand.new(self)
    end

    # Public: The demand for energy supplied through the edge.
    #
    # Returns a float, or nil if no demand can be determined.
    def demand
      get(:demand)
    end

    def wait?
      @paused || false
    end

    def wait!
      @paused = true
    end

    def continue!
      @paused = false
    end

    def inspect
      super.sub(/>$/, " (type=#{get(:type)})>")
    end

    # Public: The proportion of "carrier" energy supplied to the child node.
    #
    # "Carrier" energy means that share only accounts for other edges which
    # supply the same type of energy. So if this edge supplies 50 gas energy
    # to a node which demands 100 gas energy and 500 electricity, the edge has
    # a child share of 0.5 since it supplies half the gas.
    #
    # Returns a float, or nil if no share can be calculated.
    def child_share
      if get(:child_share)
        get(:child_share)
      elsif to.slots.in(label).edges.one?
        set(:child_share, 1.0)
      elsif demand && demand.zero?
        set(:child_share, 0.0)
      elsif to.demand && to.demand.zero?
        set(:child_share, 1.0)
      elsif demand && to.demand
        set(:child_share, demand / to.demand_for(label))
      end
    end

    # Public: The proportion of "carrier" energy supplied by the parent node.
    #
    # "Carrier" energy means that the share only accounts for other edges
    # which take away the same type of energy from the parent. So if this edge
    # takes 50 gas energy from a node which outputs 100 gas energy and 200
    # electricity, the edge has a parent share of 0.5 since it only receives
    # half of the gas.
    #
    # Returns a float, or nil if no share can be calculated.
    def parent_share
      if get(:parent_share)
        get(:parent_share)
      elsif from.slots.out(label).edges.one?
        set(:parent_share, 1.0)
      elsif demand && demand.zero?
        set(:parent_share, 0.0)
      elsif demand && from.demand &&
            from.slots.out(label).share &&
            ! from.output_of(label).zero?
        set(:parent_share, demand / from.output_of(label))
      end
    end

    # Public: The calculation priority for the edge. Only used in flex-max
    # situations.
    #
    # Returns a numeric.
    def priority
      get(:priority) || -Float::INFINITY
    end

    # Public: Determines the maximum permitted demand of this edge. Used to
    # assist in the calculation of flex-max edges, where a node has multiple
    # incoming flexible edges with priorities.
    #
    # force_recurse - Used internally to recursively determine the maximum
    #                 demand by traversing the parent node (and if necessary,
    #                 it's parents, until we can find out the max_demand.
    #
    # Returns a rational, or nil if no max demand is available.
    def max_demand(force_recurse = false)
      if get(:max_demand)
        get(:max_demand)
      elsif get(:type) == :flexible && get(:priority).nil?
        # A flexible edge with no priority is not a flex-max edge, and therefore
        # could provide all of the demand.
        set(:max_demand, Float::INFINITY)
      else
        parent_max_demand = from.max_demand(force_recurse)

        if parent_max_demand == Float::INFINITY
          # When the parent has no maximum demand, then this node must also have
          # no maximum demand.
          set(:max_demand, Float::INFINITY)
        elsif parent_max_demand && (conversion = from.slots.out(label).share)
          set(:max_demand, parent_max_demand * conversion)
        end
      end
    end
  end
end
