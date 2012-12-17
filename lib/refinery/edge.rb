module Refinery
  class Edge < Turbine::Edge
    # Public: The share calculator for the edge.
    #
    # Returns an EdgeShareCalculator.
    def calculator
      @calculator = Demand::EdgeShareCalculator.new(self)
    end

    # Public: The demand for energy supplied through the edge.
    #
    # Returns a float, or nil if no demand can be determined.
    def demand
      (get(:share) && from.demand && get(:share) * from.demand) || nil
    end
  end # Edge
end # Refinery
