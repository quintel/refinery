module Refinery
  module Catalyst
    class Calculators
      # Public: Uses the calculators in the Demand namespace in order to
      # assign demand values to nodes, and share values to edges.
      #
      # graph - The graph for which values will be computed.
      #
      # Returns the calculated graph.
      def self.call(graph)
        new(graph).run!
      end

      # Public: Creates a new Calculators catalyst.
      #
      # This catalyst will iterate through all of the nodes and edges in the
      # graph, finding those whose values can be computed. It finishes once
      # all the values have been computed.
      #
      # Returns a Calculators.
      def initialize(graph = nil, &block)
        @graph = graph
        @block = block
      end

      # Public: Runs the calculators, assuming you creates the Calculators
      # instance manually with a block.
      #
      # graph - The graph for which values will be computed.
      #
      # Returns the calculated graph.
      def call(graph)
        @graph = graph
        run!
      end

      # Public: Runs the catalyst on the +graph+.
      #
      # Returns nothing.
      def run!
        run_calculators!
        @graph
      end

      private

      # Internal: Runs the calculators, computing the demands of nodes and
      # shares of edges.
      #
      # Raises IncalculableGraph if the loop reaches a point where it is
      # impossible to compute a models value.
      #
      # Returns nothing.
      def run_calculators!
        calculators = uncalculated
        order       = 0

        while calculators.length.nonzero?
          previous_length = calculators.length

          calculators.reject! do |calculator|
            if calculator.calculable?
              begin
                calculate(calculator, order += 1)
                @block.call(calculator) if @block
                true
              rescue StandardError => ex
                ex.message.gsub!(/$/,
                  " (calculating #{calculator.model.inspect}" \
                  " using #{calculator.strategy_used.inspect})")

                raise ex
              end
            end
          end

          if calculators.length == previous_length
            # Nothing new could be calculated!
            raise IncalculableGraphError, calculators
          end
        end
      end

      # Internal: Given a single calculator, tells it to calculate it's value.
      # This can be overridden in subclasses, providing a hook into the
      # calculation process.
      def calculate(calculator, order)
        calculator.calculate!(order) || true
      end

      # Internal: Returns all uncalculated calculators from nodes and edges
      # in the graph.
      #
      # Returns an array of calculators.
      def uncalculated
        @graph.tsort { |e| e.get(:type) != :overflow }.map do |node|
          [ node.calculator, *node.out_edges.map(&:calculator).to_a ]
        end.flatten.reject(&:calculated?).reject(&:paused?).reverse
      end
    end
  end
end
