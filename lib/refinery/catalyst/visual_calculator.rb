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
        draw(Diagram::InitialValues, '00000')

        result = run!

        # Draw a final graph without the bolded arrow representing the most
        # recently calculated element.
        draw(Diagram, '99999')

        result
      rescue IncalculableGraphError => ex
        draw(Diagram::Calculable,   '99999-calculable')
        draw(Diagram::Incalculable, '99999-incalculable')
      end

      #######
      private
      #######

      # Internal: Given a single calculator, tells it to calculate it's value.
      # This can be overridden in subclasses, providing a hook into the
      # calculation process.
      def calculate(calculator, order)
        super
        draw(Diagram::Focused, '%05d' % order, calculator.model)

        true
      end

      # Internal: Given a diagram class, draws the diagram to the given
      # +filename+ (within +@directory+, omit the extension). Additional
      # +*args+ will be given to the diagram when initialzied.
      def draw(klass, filename, *args)
        klass.new(@graph, *args).draw_to(@directory.join("#{ filename }.png"))
      end
    end # VisualCalculator
  end # Catalyst
end # Refinery
