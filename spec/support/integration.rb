module Refinery::Spec
  module Integration
    # Public: The graph for the current spec example.
    #
    # Returns a Turbine::Graph.
    def graph
      @turbine ||= Turbine::Graph.new
    end

    # Public: Calculates demand and edge shares for the graph. If the graph
    # cannot be calcualted, no error is raised.
    #
    # Returns nothing.
    def calculate!
      Refinery::Reactor.new(
        Refinery::Catalyst::ConvertFinalDemand,
        Refinery::Catalyst::AssignSlots,
        Refinery::Catalyst::Calculators
      ).run(graph)
    rescue Refinery::IncalculableGraphError
    end
  end # Integration
end # Refinery::Spec
