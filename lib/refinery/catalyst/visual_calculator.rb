module Refinery
  module Catalyst
    # Creates a diagram for each step in the calculations. Use like so:
    #
    #    Refinery::Reactor.new(
    #     Refinery::Catalyst::VisualCalculator.new(directory),
    #     Refinery::Catalyst::Validation
    #   ).run(graph)
    #
    class VisualCalculator < Calculators
      # Public: Creates a new VisualCalculator. This will output a diagram
      # after each individual calculation is performed, allowing the user to
      # see a visual representation of what Refinery is doing.
      #
      # directory - A directory in which to write the diagram PNGs.
      #
      # Returns a VisualCalculator.
      def initialize(directory)
        super(nil)
        @directory = Pathname.new(directory)
      end

      # Public: Runs the calculation.
      #
      # Returns the graph.
      def call(graph)
        @graph = graph
        FileUtils.mkdir_p(@directory)

        # Draw a final graph without the bolded arrow representing the most
        # recently calculated element.
        Diagram::InitialValues.new(@graph).draw_to(@directory.join('00000.png'))

        result = run!

        # Draw a final graph without the bolded arrow representing the most
        # recently calculated element.
        Diagram.new(@graph).draw_to(@directory.join('99999.png'))

        result
      end

      #######
      private
      #######

      # Internal: Given a single calculator, tells it to calculate it's value.
      # This can be overridden in subclasses, providing a hook into the
      # calculation process.
      def calculate(calculator, order)
        super

        Diagram::Focused.new(@graph, calculator.model).
          draw_to(@directory.join("%05d.png" % order))

        true
      end
    end # VisualCalculator
  end # Catalyst
end # Refinery
