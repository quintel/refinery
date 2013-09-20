module Refinery
  module Calculators
    # Calculates the total expected or preset demand of a node by looking
    # either to the child nodes, or to a parent node.
    class EdgeDemand < Base
      include Strategies::EdgeDemand
      DEFAULT_STRATEGIES = [
        FillRemaining.compile(:forwards).new,
        ByShare.compile(:reversed).new,
        ByShare.compile(:forwards).new,
        FromDemand.compile(:forwards).new,
        FromDemand.compile(:reversed).new,
        FillRemaining.compile(:reversed).new,
        FillRemainingAcrossSlots.compile(:reversed).new,
        FillRemainingAcrossSlots.compile(:forwards).new,
        Solo.compile(:forwards).new,
        Solo.compile(:reversed).new
      ]

      # Public: Performs the calculation, setting the demand attribute on the
      # node.
      #
      # Returns nothing.
      def calculate!(order)
        super

        @model.set(:demand, [
          # Disallow the calculated value from exceeding the demand specified
          # by the node -- assuming we already know what that demand is.
          strategy.calculate(@model),
          @model.to.demand_for(@model.label),
          @model.from.output_of(@model.label)
        ].compact.min)
      end

      # Public: Has a demand value been set for the node?
      #
      # Returns true or false.
      def calculated?
        super || @model.demand
      end

      #######
      private
      #######

      # Internal: An array containing the strategies which may be used to
      # calculate the edge.
      #
      # Returns an array of strategies.
      def applicable_strategies
        case @model.get(:type)
        when :overflow
          [ Overflow.new, Solo.compile(:reversed).new ]
        when :flexible
          [ Solo.compile(:forwards).new,
            ByShare.compile(:reversed).new,
            ByShare.compile(:forwards).new,
            Flexible.new ]
        else
          super
        end
      end
    end # EdgeDemand
  end # Calculators
end # Refinery
