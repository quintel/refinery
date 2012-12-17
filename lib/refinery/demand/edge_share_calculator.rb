module Refinery
  module Demand
    class EdgeShareCalculator < Calculator
      STRATEGIES = [
        Strategies::Share::Solo,
        Strategies::Share::FillRemaining,
        Strategies::Share::InferFromChild,
        Strategies::Share::FromDemand
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
    end # EdgeShareCalculator
  end # Demand
end # Refinery
