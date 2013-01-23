module Refinery::Spec
  module Integration
    # Public: The graph for the current spec example.
    #
    # Returns a Turbine::Graph.
    def graph
      @turbine ||= Turbine::Graph.new
    end

    # Public: Literate helper for testing node and edge demands using the
    # "have_calculated_value" matcher.
    #
    # For example:
    #
    #   # Assert that a demand was calculated. It can be any numeric value.
    #   expect(node).to have_demand
    #
    #   # Assert that no demand figure was calculated.
    #   expect(node).to_not have_demand
    #
    #   # Assert that a specific demand was calculated.
    #   expect(node).to have_demand(45)
    #
    # Returns an RSpec matcher.
    def have_demand
      have_calculated_value(:demand)
    end

    # Public: Literate helper for testing edge child shares using the
    # "have_calculated_value" matcher.
    #
    # For example:
    #
    #   # Assert that a demand was calculated. It can be any numeric value.
    #   expect(node).to have_child_share
    #
    #   # Assert that no demand figure was calculated.
    #   expect(node).to_not have_child_share.of(0.5)
    #
    # Returns an RSpec matcher.
    def have_child_share
      have_calculated_value(:child_share)
    end

    # Public: Calculates demand and edge shares for the graph. If the graph
    # cannot be calcualted, no error is raised.
    #
    # Returns nothing.
    def calculate!
      Refinery::Reactor.new(
        Refinery::Catalyst::ConvertFinalDemand,
        Refinery::Catalyst::Calculators
      ).run(graph)
    rescue Refinery::IncalculableGraphError
    end
  end # Integration
end # Refinery::Spec
