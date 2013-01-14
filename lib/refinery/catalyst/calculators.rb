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
        validate_slot_shares!
        run_calculators!
      end

      #######
      private
      #######

      # Internal: Runs the calculators, computing the demands of nodes and
      # shares of edges.
      #
      # Raises IncalculableGraph if the loop reaches a point where it is
      # impossible to compute a models value.
      #
      # Returns nothing.
      def run_calculators!
        calculators = uncalculated
        cycle       = 0
        order       = 0

        while calculators.length.nonzero?
          previous_length = calculators.length

          calculators.reject! do |calculator|
            # calculator.calculable? && (calculator.calculate! || true)
            if calculator.calculated?
              # Some calculators are used just to create a temporary value
              # used to assist in calculating something else (e.g. output
              # share is used to assist in calculating "input" share).
              true
            elsif calculator.calculable?
              (calculator.calculate!(order += 1) || true)
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
        calculators = @graph.nodes.map(&:calculator)

        @graph.nodes.each do |node|
          calculators.concat(node.out_edges.map(&:calculator).to_a)
        end

        calculators.reject(&:calculated?)
      end

      # Internal: Asserts that the in and out slots for each node sum up to
      # 1.0. This is mostly a sanity check which asserts that:
      #
      #   1. Nodes are only automatically assigned a single slot on each side
      #      (we can't magically know that CHPs need to output 70% heat and
      #      30% electricity, a user has to input this manually).
      #
      #   2. Nodes which have user-assigned slots were given sensible shares.
      #
      # Raises InvalidSlotSumError if any node failed the above conditions.
      #
      # Returns nothing.
      def validate_slot_shares!
        @graph.nodes.each do |node|
          # assert_valid_slot_shares(node, :in)
          assert_valid_slot_shares(node, :out)
        end
      end

      # Internal: Asserts that the slots on a single side of a node add up to
      # 1.0. See validate_slot_shares!
      #
      # Returns nothing.
      def assert_valid_slot_shares(node, direction)
        return true if node.slots.public_send(direction).empty?

        sum = node.slots.public_send(direction).sum { |s| s.get(:share) }
        raise InvalidSlotSumError.new(node, direction, sum) if sum != 1.0
      end
    end # Calculators
  end # Catalyst
end # Refinery
