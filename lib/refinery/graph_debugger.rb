module Refinery
  # Given a graph, prints information about the calculation strategies
  # which were used to compute demands for the elements in the graph, and the
  # order in which each was run.
  class GraphDebugger
    # Public: Creates a new GraphDebugger.
    #
    # graph - The graph whose information you want to show.
    #
    # Returns a GraphDebugger.
    def initialize(graph)
      @graph = graph
    end

    # Public: Creates the string with all the debug information.
    #
    # For example:
    #
    #   puts GraphDebugger.new(graph)
    #
    # Returns a string.
    def to_s
      table = Terminal::Table.new(
        headings: %w( # Element Strategy Value ),
        rows: calculators.map do |calc|
          [ calc.order,
            format_element(calc.model),
            calc.strategy_used.to_s.gsub(/^Refinery::Strategies::/, ''),
            element_value(calc.model) ]
        end
      )

      table.align_column(0, :right)
      table.align_column(3, :right)

      table.to_s
    end

    #######
    private
    #######

    # Internal: All the calculators which ran and computed a value for their
    # graph element.
    #
    # Returns an array of Calculators.
    def calculators
      calculators = @graph.nodes.map do |node|
        [ node.calculator, *node.out_edges.map(&:calculator) ]
      end.flatten

      calculators.select(&:order).sort_by(&:order)
    end

    # Internal: Formats the element associated with the calculator so that it
    # can be shown to the user.
    #
    # Returns a string.
    def format_element(element)
      element.kind_of?(Node) ? "[#{ element.key.inspect }]" : element.to_s
    end

    # Internal: The value which was computed by the calculator. This is
    # normally a BigDecimal, so it gets formatted to a human-readable
    # notation.
    #
    # Returns a string.
    def element_value(element)
      element.demand ? '%.10g' % element.demand : 'FAIL'
    end
  end # GraphDebugger
end # Refinery
