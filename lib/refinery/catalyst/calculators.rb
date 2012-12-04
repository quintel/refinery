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
      # Returns nothing.
      def run!
        convert_final_demand!
        assign_calculators!
        run_calculators!
      end

      #######
      private
      #######

      # Internal: Any nodes with a :final_demand attribute will have their
      # :expected_demand values set also.
      #
      # Returns nothing.
      def convert_final_demand!
        @graph.nodes.select { |node| node.get(:final_demand) }.each do |node|
          node.set(:expected_demand, node.get(:final_demand))
        end
      end

      # Internal: Given a node, assigns the calculators.
      #
      # node - The node.
      #
      # Returns nothing.
      def assign_calculators!
        @graph.nodes.each do |node|
          node.set(:calculator, Demand::NodeDemandCalculator.new(node))

          node.out_edges.each do |edge|
            edge.set(:calculator, Demand::EdgeShareCalculator.new(edge))
          end
        end
      end

      # Internal: Calculates the values for each node and edge.
      #
      # Raises IncalculableGraph if the loop reaches a point where it is
      # impossible to compute a models value.
      #
      # Returns nothing.
      def run_calculators!
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

      # Internal: Returns all uncalculated calculators from nodes and edges
      # in the graph.
      #
      # Returns an array of calculators.
      def uncalculated
        calculators = @graph.nodes.map { |node| node.get(:calculator) }

        @graph.nodes.each do |node|
          calculators.concat(node.out_edges.get(:calculator).to_a)
        end

        calculators.reject(&:calculated?)
      end
    end # Calculators
  end # Catalyst
end # Refinery
