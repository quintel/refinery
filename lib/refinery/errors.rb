module Refinery
  # Error class which serves as a base for all errors which occur in Refinery.
  RefineryError = Class.new(RuntimeError)

  # Internal: Creates a new error class which inherits from RefineryError,
  # whose message is created by evaluating the block you give.
  #
  # For example
  #
  #   MyError = error_class do |weight, limit|
  #     "#{ weight } exceeds #{ limit }"
  #   end
  #
  #   raise MyError.new(5000, 2500)
  #   # => #<Refinery::MyError: 5000 exceeds 2500>
  #
  # Returns an exception class.
  def self.error_class(superclass = RefineryError, &block)
    Class.new(superclass) do
      def initialize(*args) ; super(make_message(*args)) ; end
      define_method(:make_message, &block)
    end
  end

  # Raised when performing the demand calculation loop, but a point was
  # reached where it is impossible to continue calculating.
  IncalculableGraphError = error_class do |remaining_models|
    elements = remaining_models.map do |model|
      "  * #{ model.to_s }"
    end.join("\n")

    "The following graph elements had insufficient data to be " \
    "calculated: \n\n#{ elements }"
  end

  # Raised when the sum of the slot shares on one side of a node do not add up
  # to 1.0.
  InvalidSlotSumError = error_class do |node, direction, sum|
    adjective = direction == :in ? 'incoming' : 'outgoing'

    "#{ node.inspect } has invalid #{ adjective } slots. The sum of their " \
    "shares should be 1.0, but it was #{ sum }"
  end

  # Raised when adding a slot to a node which is already present.
  SlotAlreadyExistsError = error_class do |node, direction, carrier|
    adjective = direction == :in ? 'incoming' : 'outgoing'
    "#{ node.inspect } already has an #{ adjective } #{ carrier } slot."
  end

  # Raised when a asking for a slot which does not exist.
  NoSuchCarrierError = error_class do |node, direction, carrier|
    adjective = direction == :in ? 'incoming' : 'outgoing'
    "#{ node.inspect } has no #{ adjective } #{ carrier.inspect } slot."
  end

  # Raised by the Validation catalyst if any errors were detected after the
  # demand calculations were performed.
  FailedValidationError = error_class do |errors|
    failures = errors.map do |slot, messages|
      messages.map { |message| "  * #{ slot.inspect } #{ message }" }
    end.flatten.join("\n")

    "Post-calculation validations failed with the following " \
    "errors:\n\n#{ failures }"
  end
end # Refinery
