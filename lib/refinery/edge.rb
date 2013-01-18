module Refinery
  class Edge < Turbine::Edge
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

    # Public: The proportion of "carrier" energy supplied to the child node.
    #
    # "Carrier" energy means that share only accounts for other edges which
    # supply the same type of energy. So if this edge supplies 50 gas energy
    # to a node which demands 100 gas energy and 500 electricity, the edge has
    # a share of 0.5 since it supplies half the gas.
    #
    # Returns a float, or nil if no share can be calculated.
    def share
      if get(:share)
        get(:share)
      elsif to.slots.in(label).edges.one?
        set(:share, 1.0)
      elsif demand && demand.zero?
        set(:share, 0.0)
      elsif demand && to.demand
        set(:share, demand / to.demand_for(label))
      end
    end
  end # Edge
end # Refinery
