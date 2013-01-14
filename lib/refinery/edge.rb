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
      if get(:demand)
        get(:demand)
      elsif get(:share) && to.demand
        to.demand * to.slots.in(label).get(:share) * get(:share)
      elsif get(:output_share) && from.demand
        from.demand * from.slots.out(label).get(:share) * get(:output_share)
      end
    end
  end # Edge
end # Refinery
