module Refinery
  module UseBigDecimal
    # Internal: Callback run when you execute `include UseBigDecimal`.
    #
    # Returns nothing.
    def self.included(base)
      unless base < Turbine::Properties
        raise "You can only include UseBigDecimal on classes which also " \
              "include Turbine::Properties."
      end

      base.extend(ClassMethods)
    end

    # Public: Sets a property on the object.
    #
    # Properties specified in +use_big_decimal+ will be cast to a BigDecimal
    # unless the given +value+ is nil. All other properties will be set
    # without any changes.
    #
    # key   - The name of the property to be set.
    # value - The value to be set.
    #
    # For example
    #
    #    class Drill
    #      include UseBigDecimal
    #      use_big_decimal :share
    #    end
    #
    #    drill = Drill.new(share: 1.0, lifetime: 3.0)
    #
    #    drill.get(:share)    #=> #<BigDecimal 1.0>
    #    drill.get(:lifetime) #=> 3.0
    #
    # See Turbine::Properties.
    def set(key, value)
      if value && self.class.properties_using_big_decimal.include?(key)
        super(key, value.to_d)
      else
        super
      end
    end

    # Public: Mass assign properties to the object.
    #
    # Like +set+, casts specified properties to a BigDecimal.
    #
    # Returns the properties.
    def properties=(properties)
      super({})

      unless properties.nil?
        properties.each { |key, value| set(key, value) }
      end

      self.properties
    end

    module ClassMethods
      # Public: Specifies that values set to the +properties+ should be cast
      # to a BigDecimal before they are set on the class.
      #
      # properties - An array of property names.
      #
      # Returns nothing.
      def use_big_decimal(*properties)
        properties_using_big_decimal.push(*properties.map(&:to_sym))
        nil
      end

      # Internal: The array containing all of the properties whose values
      # should be cast to BigDecimals.
      #
      # Returns an array of symbols.
      def properties_using_big_decimal
        @properties_using_big_decimal ||= []
      end
    end # ClassMethods
  end # UseBigDecimal
end # Refinery
