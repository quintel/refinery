module Refinery
  module Demand
    # For demand calculations, each node and edge receive a calculator which
    # is capable of assigning the necessary values (such as expected demand,
    # link share, etc).
    class Calculator
      # Public: Creates a new calculator responsible for figuring out the
      # unknown attributes for the given +model+. Calculator is a base class
      # and should be extended with the logic needed to compute the values.
      #
      # model - The Turbine node or edge.
      #
      # Returns a Calculator.
      def initialize(model)
        @model      = model
        @calculated = false
      end

      # Public: Does the instance have all the data it needs to perform its
      # calculation?
      #
      # Returns true or false.
      def calculable?
        raise NotImplementedError, 'Implement calculable? in a subclass.'
      end

      # Public: Performs the calculation, setting the appropriate attributes
      # on the model.
      #
      # Returns nothing.
      def calculate!
        @calculated = true
      end

      # Public: Returns if the calculator has previously been successfully
      # run.
      #
      # Returns true or false.
      def calculated?
        @calculated
      end

      # Public: A human-readable version of the calculator for debugging.
      #
      # Returns a string.
      def inspect
        "#<#{ self.class.name } (#{ @model.inspect })>"
      end

      # Public: A pretty version of the calculator.
      #
      # Returns a string.
      def to_s
        "#{ self.class.name.gsub(/.+::/, '') } for #{ @model.inspect }"
      end
    end # Calculator
  end # Demand
end # Refinery
