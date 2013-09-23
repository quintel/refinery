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
    #   # Assert that a child share can be calculated.
    #   expect(node).to have_child_share
    #
    #   # Assert that a specific share was calculated.
    #   expect(node).to have_child_share.of(0.5)
    #
    # Returns an RSpec matcher.
    def have_child_share
      have_calculated_value(:child_share)
    end

    # Public: Literate helper for testing edge parent shares using the
    # "have_calculated_value" matcher.
    #
    # For example:
    #
    #   # Assert that a parent share can be calculated.
    #   expect(node).to have_parent_share
    #
    #   # Assert that a specific share was calculated.
    #   expect(node).to have_parent_share.of(0.5)
    #
    # Returns an RSpec matcher.
    def have_parent_share
      have_calculated_value(:parent_share)
    end

    # Public: Calculates demand and edge shares for the graph. If the graph
    # cannot be calculated, no error is raised.
    #
    # debug - Uses the VisualCalculator to draw diagrams of the graph in each
    #         step of the calculation. Diagrams are drawn to tmp/debug.
    #
    # Returns nothing.
    def calculate!(debug = false)
      if debug
        calculate_and_debug!
      else
        do_calculate!(Refinery::Catalyst::Calculators)
      end

      graph
    end

    #######
    private
    #######

    # Internal: Runs calculation of the graph, outputting relevant debugging
    # information to tmp/debug.
    #
    # Returns nothing.
    def calculate_and_debug!
      directory = Pathname.new('tmp/debug')

      FileUtils.mkdir_p(directory)
      directory.children.each { |child| child.delete }

      do_calculate!(Refinery::Catalyst::VisualCalculator.new(directory))

      File.write(directory.join('_d.txt'), Refinery::GraphDebugger.new(graph))

    end

    # Internal: Runs the calcualtion of the graph.
    #
    # Returns nothing.
    def do_calculate!(catalyst)
      [ Refinery::Catalyst::ConvertFinalDemand, catalyst ]
        .reduce(graph) { |result, catalyst| catalyst.call(result) }
    rescue Refinery::IncalculableGraphError
    end
  end # Integration
end # Refinery::Spec
