module Refinery
  module Demand
    class EdgeShareCalculator < Calculator
      STRATEGIES = [
        Strategies::Share::Solo,
        Strategies::Share::FillRemaining,
        Strategies::Share::InferFromChild
      ]

      # Public: Performs the calculation, setting the share attribute on the
      # edge.
      #
      # Returns nothing.
      def calculate!
        @model.set(:share, strategy.calculate(@model))
        super
      end

      # Public: Return if this calculator has already set a value.
      #
      # Returns true or false.
      def calculated?
        super || @model.get(:share)
      end

      # Public: Calculates the energy demand which is assigned to this edge. A
      # value can only be computed if the "from" node has a demand value
      # assigned, and the edge has a share.
      #
      # Returns a float, or nil if the calculation is not possible.
      def demand
        if @model.get(:share) && @model.from.get(:calculator).demand
          @model.from.get(:calculator).demand * @model.get(:share)
        end
      end
    end # EdgeShareCalculator
  end # Demand
end # Refinery
