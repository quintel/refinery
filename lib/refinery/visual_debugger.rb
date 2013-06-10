module Refinery
  # Given a calculated (or partially calculated) graph, creates a diagram for
  # each step in the calculation.
  #
  # This will allow you to see, in diagram form, how Refinery assigned values
  # to each node and edge, and in which order. To do this, the debugger starts
  # with the node or edge which last calculated it's value, removes it, and
  # creates the diagram. It does this until the original state of the graph is
  # reached. As a result, the original graph is destroyed and should not be
  # used any further. A Graph#dup will be added to Turbine or Refinery soon to
  # resolve this.
  class VisualDebugger
    def initialize(graph)
      @graph = graph
    end

    # Public: Draws a diagram for each step in the Refinery calculations to
    # the given +directory+.
    #
    # Returns nothing.
    def draw_to(directory)
      directory = Pathname.new(directory)

      each_step do |step, calculator|
        draw_diagram(step, directory, calculator.model)
        calculator.model.set(:demand, nil)
      end

      draw_diagram(0, directory)
    end

    #######
    private
    #######

    # Internal: Iterates backwards through each calculation which was made by
    # Refinery, yielding the calculation step ("order") number, and the
    # calculator which was run.
    #
    # Returns nothing.
    def each_step
      calculators = @graph.nodes.map do |node|
        [ node.calculator, *node.out_edges.map(&:calculator) ]
      end

      calculators.flatten!
      calculators.select!(&:order)
      calculators.sort_by! { |calculator| -calculator.order }

      calculators.each do |calculator|
        yield calculator.order, calculator
      end
    end

    # Internal: Given a +step+ number, draws the graph in its current state to
    # the +directory+ specified.
    #
    # Returns nothing.
    def draw_diagram(step, directory, focus = nil)
      diagram = if focus.nil?
        Diagram.new(@graph)
      else
        Diagram::Focused.new(@graph, focus)
      end

      diagram.draw_to(directory.join("#{ step }.png"))
    end

  end # VisualDebugger
end # Refinery
