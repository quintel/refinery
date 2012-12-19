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

  # Added a node to a graph, when one already exists with the same key.

  # Raised when performing the demand calculation loop, but a point was
  # reached where it is impossible to continue calculating.
  IncalculableGraphError = error_class do |remaining_models|
    elements = remaining_models.map do |model|
      "  * #{ model.to_s }"
    end.join("\n")

    "The following graph elements had insufficient data to be " \
    "calculated: \n\n#{ elements }"
  end

  # Raised if an edge has more than one slot in a direction without a share
  # already set.
  TooManySlotsError = error_class do |node, direction|
    "#{ node.inspect } has too many #{ direction } slots without a " \
    "predefined share; the maximum is one."
  end

  # Raised when adding a slot to a node which is already present.
  SlotAlreadyExistsError = error_class do |node, direction, carrier|
    adjective = direction == :in ? 'incoming' : 'outgoing'
    "#{ node.inspect } already has an #{ adjective } #{ carrier } slot."
  end
end # Refinery
