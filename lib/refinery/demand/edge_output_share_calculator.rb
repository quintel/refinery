module Refinery
  module Demand
    class EdgeOutputShareCalculator < Calculator
      STRATEGIES = [ Strategies::OutputShare::Solo ]

      # Public: Performs the calculation, setting the share attribute on the
      # edge.
      #
      # Returns nothing.
      def calculate!(order)
        unless @model.get(:share)
          @model.set(:output_share, strategy.calculate(@model))
        end

        @calculated = true
      end

      # Public: Return if this calculator has already set a value.
      #
      # Returns true or false.
      def calculated?
        super || @model.get(:share) || @model.get(:output_share)
      end
    end # EdgeOutputShareCalculator
  end # Demand
end # Refinery
