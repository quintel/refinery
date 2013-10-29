module Refinery
  module Catalyst
    class Validation
      # The factor by which a slot demand is allowed to disagree with the demand
      # of the node. 1e-15 is 0.000000000001%.
      PERMITTED_SLOT_DEVIATION = 1e-14

      # Public: Given a graph, asserts that the demands were all set
      # correctly, and that there were no anomalous results. Bad demand
      # calculations are typically the result of user error. If the user gives
      # this data...
      #
      #   (50) [A] [B] (50)
      #          \ /
      #          [X] (50)
      #
      # ... Refinery will not be able to calculate meaningful demands for the
      # two edges. The Validation class will catch this.
      #
      # Raises a FailedValidationError if there were any validation errors.
      #
      # Returns nothing.
      def self.call(graph)
        validator = new(graph).run!

        if validator.errors.any?
          fail Refinery::FailedValidationError.new(validator.errors)
        end

        graph
      end

      # Strings for the various error messages.
      MESSAGES = {
        missing_demand:      'has no demand value set',
        non_matching_demand: 'demand (%s) does not match %s the node (%s) (%s)',
        undetermined_share:  'has an undetermined share',
        max_demand_exceeded: 'demand (%s) exceeds max_demand (%s)'
      }.freeze

      # Public: Returns the errors. This will be an empty hash if no errors
      # were found during validation, or if the validation is yet to be run.
      attr_reader :errors

      # Public: Creates a new Validation catalyst. This iterates through each
      # node and checks that its incoming and outgoing links have demands
      # identical to the demand of the node.
      #
      # graph - The graph to be validated.
      #
      # Returns a Validation.
      def initialize(graph)
        @graph  = graph
        @errors = {}
      end

      # Public: Runs the validation on all nodes in the graph.
      #
      # Returns self.
      def run!
        @graph.nodes.each do |node|
          if node.demand.nil?
            # Associated slots and edges will obviously be invalid if the node
            # has no demand, so we don't even bother testing them.
            add_error(node, :missing_demand)
          else
            validate_node(node)

            (node.slots.in.to_a + node.slots.out.to_a).each do |slot|
              validate_slot(slot) if slot.edges.any?
            end
          end
        end

        self
      end

      # Public: Determines if there were any errors when running the
      # validation.
      #
      # Returns true or false.
      def errors?
        @errors.any?
      end

      #######
      private
      #######

      # Internal: Given a node, asserts that energy coming in equals that
      # which leaves.
      #
      # node - The slot to be validated.
      #
      # Returns nothing.
      def validate_node(node)
        if node.max_demand && node.demand > node.max_demand
          add_error(node, :max_demand_exceeded,
                    format_energy(node.demand),
                    format_energy(node.max_demand))
        end
      end

      # Internal: Given a slot, validates that demand was calculated for all
      # of its edges and that the demand of the slot matches the demand or
      # output for the carrier in the node.
      #
      # slot - The slot to be validated.
      #
      # Returns nothing.
      def validate_slot(slot)
        demandless = slot.edges.reject(&:demand)
        transform  = slot.direction == :in ? :demand_for : :output_of
        expected   = slot.node.public_send(transform, slot.carrier)

        if demandless.any?
          # We only need to alert that an edge is missing demand once; so we
          # ignore this error on :in slots.
          if slot.direction == :out
            demandless.each { |edge| add_error(edge, :missing_demand) }
          end
        elsif slot.demand.nil?
          add_error(slot, :missing_demand)
        elsif slot.share.nil?
          add_error(slot, :undetermined_share)
        elsif deviant_slot_demand?(slot)
          add_error(
            slot, :non_matching_demand,
            format_energy(slot.demand),
            slot.direction == :in ? 'demand from' : 'output of',
            format_energy(expected_slot_demand(slot)),
            format_energy(slot.demand - expected_slot_demand(slot), '%-+f'))
        end
      end

      # Internal: Adds an error to the validator.
      #
      # object  - The object whose value was not what we expected.
      # message - A message describing the validation which failed.
      #
      # Returns nothing.
      def add_error(object, key, *details)
        details = details.map do |detail|
          detail.is_a?(Rational) ? '%f' % detail : detail
        end

        @errors[object] ||= []
        @errors[object].push(MESSAGES[key] % details)

        nil
      end

      # Internal: Determines if the demand of a slot differs substantially from
      # the value we would expected when multiplying the demand of the node by
      # the slot conversion.
      #
      # The demand is allowed to disagree with the node by a tiny amount ––
      # in the larger nodes in big countries (e.g. Germany) the variation comes
      # to about one megajoule.
      #
      # See: https://github.com/quintel/etsource/issues/555
      #
      # slot - The slot to check.
      #
      # Returns true or false.
      def deviant_slot_demand?(slot)
        expected = expected_slot_demand(slot)
        permitted_deviation = expected * PERMITTED_SLOT_DEVIATION

        (expected - permitted_deviation) > slot.demand ||
          (expected + permitted_deviation) < slot.demand
      end

      # Internal: Given a slot, returns how much demand it's edges are expected
      # to have, according to the node.
      #
      # Returns a numeric.
      def expected_slot_demand(slot)
        slot.node.public_send(
          slot.direction == :in ? :demand_for : :output_of, slot.carrier)
      end

      # Internal: Given an energy value in petajoules, formats it nicely,
      # converting it to terajoules, gigajoules, etc, as necessary, and
      # inserting delimiters between each thousand.
      #
      # Returns a string.
      def format_energy(value, format_string = '%f')
        return 'nil' if value.nil?

        formatted = if value.abs < (1.0 / 1_000_000_000_000)
          "#{ sprintf(format_string, value * 1_000_000_000_000) } KJ"
        elsif value < (1.0 / 1_000_000_000)
          "#{ sprintf(format_string, value * 1_000_000_000) } MJ"
        elsif value < (1.0 / 1_000_000)
          "#{ sprintf(format_string, value * 1_000_000) } GJ"
        elsif value < (1.0 / 1_000)
          "#{ sprintf(format_string, value * 1_000) } TJ"
        else
          "#{ sprintf(format_string, value) } PJ"
        end

        parts = formatted.split('.')

        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
        parts[1].gsub!(/0+ /, ' ')

        parts[1][0] == ' ' ? parts.join : parts.join('.')
      end
    end # Validation
  end # Catalyst
end # Refinery
