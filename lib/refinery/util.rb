module Refinery
  # Contains helpful methods which don't belong anywhere else.
  module Util
    module_function

    # Public: Given an enumerable, sums each value. Unlike Enumerable#sum in
    # that it will return nil if any element's value is nil.
    #
    # For example
    #
    #   Util.strict_sum([ 1.2, 4.5, 2.3 ]) { |element| element.to_i }
    #   # => Rational(7)
    #
    #   Util.strict_sum([ 1, 2, nil, 4 ])
    #   # => nil
    #
    # Returns a rational, or nil.
    def strict_sum(enumerable)
      enumerable = enumerable.to_a

      return nil if enumerable.none?

      enumerable.reduce(Rational(0)) do |sum, element|
        value = block_given? ? yield(element) : element
        value.nil? ? (return nil) : sum + value
      end
    end
  end
end
