module Refinery
  module Catalyst
    class Calculators
      # Public: Uses the calculators in the Demand namespace in order to
      # assign demand values to nodes, and share values to edges.
      #
      # graph - The graph for which values will be computed.
      #
      # Returns nothing.
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
      def initialize(graph)
        @graph = graph
      end

      # Public: Runs the catalyst on the +graph+.
      #
      # Raises IncalculableGraph if the loop reaches a point where it is
      # impossible to compute a models value.
      #
      # Returns nothing.
      def run!
        calculators = uncalculated
        cycle       = 0

        while calculators.length.nonzero?
          previous_length = calculators.length

          calculators.reject! do |calculator|
            # calculator.calculable? && (calculator.calculate! || true)
            if calculator.calculable?
              (calculator.calculate! || true)
            end
          end

          if calculators.length == previous_length
            # Nothing new could be calculated!
            raise IncalculableGraphError.new(calculators)
          end
        end
      end

      #######
      private
      #######

      # Internal: Returns all uncalculated calculators from nodes and edges
      # in the graph.
      #
      # Returns an array of calculators.
      def uncalculated
        calculators = @graph.nodes.map(&:calculator)

        @graph.nodes.each do |node|
          calculators.concat(node.out_edges.map(&:calculator).to_a)
        end

        calculators.reject(&:calculated?)
      end
    end # Calculators
  end # Catalyst
end # Refinery
