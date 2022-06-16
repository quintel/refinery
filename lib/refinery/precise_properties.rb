module Refinery
  # Defines a that a property on a Node or Edge is numeric and should be
  # converted to a Rational to ensure no loss of precision.
  module PreciseProperties
    # Internal: Callback run when you execute `include PreciseProperties`.
    #
    # Returns nothing.
    def self.included(base)
      unless base < Turbine::Properties
        raise 'You can only include PreciseProperties on classes which ' \
              'also include Turbine::Properties.'
      end

      base.extend(ClassMethods)
    end

    # Public: Sets a property on the object.
    #
    # Properties specified in +precise_property+ will be cast to a Rational
    # unless the given +value+ is nil. All other properties will be set
    # without any changes.
    #
    # key   - The name of the property to be set.
    # value - The value to be set.
    #
    # For example
    #
    #    class Drill
    #      include Refinery::PreciseProperties
    #      precise_property :share
    #    end
    #
    #    drill = Drill.new(share: 1.0, lifetime: 3.0)
    #
    #    drill.get(:share)    #=> #<Rational (1/1)>
    #    drill.get(:lifetime) #=> 3.0
    #
    # See Turbine::Properties.
    def set(key, value)
      if value && self.class.precise_properties.include?(key)
        value = value.is_a?(Rational) ? value : Rational(value.to_s)
        value = Rational(0) if value < 0
      end

      super(key, value)
    end

    # Public: Mass assign properties to the object.
    #
    # Like +set+, casts specified properties to a Rational.
    #
    # Returns the properties.
    def properties=(properties)
      super({})

      properties.each { |key, value| set(key, value) } unless properties.nil?

      self.properties
    end

    module ClassMethods
      # Public: Specifies that values set to the +properties+ should be cast
      # to a Rational before they are set on the class.
      #
      # properties - An array of property names.
      #
      # Returns nothing.
      def precise_property(*properties)
        precise_properties.push(*properties.map(&:to_sym))
        nil
      end

      # Internal: The array containing all of the properties whose values
      # should be cast to Rational.
      #
      # Returns an array of symbols.
      def precise_properties
        @precise_properties ||= []
      end
    end
  end
end
