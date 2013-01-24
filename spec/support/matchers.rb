# Used to provide nice matching of node demands and edge shares. Typically
# used via the "have_demand" and "have_share" matchers in integration tests
# only.
#
# Usage:
#
#   # Assert that a demand was calculated. It can be any numeric value.
#   expect(node).to have_demand
#
#   # Assert that no demand figure was calculated.
#   expect(node).to_not have_demand
#
#   # Assert that demand was calculated, and that it was a specific value.
#   expect(node).to have_demand.of(50.0)
#
#   # Assert that demand was calculated, but that it was not a specific value.
#   expect(node).to have_demand.of(666.0)
#
RSpec::Matchers.define :have_calculated_value do |attribute, fetcher = nil|
  @fetcher   = fetcher
  @attribute = attribute

  def format(number)
    number.kind_of?(Rational) ? '%.10g' % number : number.inspect
  end

  def actual(model)
    value = if @fetcher.nil?
      model.public_send(@attribute)
    else
      @fetcher.call(model)
    end

    value.nil? ? nil : value.to_f
  end

  match do |model|
    value = actual(model)

    if @expectation
      (! value.nil?) &&
        value > (@expectation - 1e-9) &&
        value < (@expectation + 1e-9)
    else
      ! value.nil?
    end
  end

  chain :of do |expectation|
    @expectation = expectation.to_f
  end

  failure_message_for_should do |model|
    if @expectation
      "expected #{ model } to have #{ attribute } " \
      "#{ format(@expectation) }, but it was " \
      "#{ format(actual(model)) }"
    else
      "expected #{ model } to have #{ attribute } calculated"
    end
  end

  failure_message_for_should_not do |model|
    if @expectation
      "expected #{ model } to not have #{ attribute } of " \
      "#{ format(@expectation) }"
    else
      "expected #{ model } to not have #{ attribute } calculated, but it " \
      "was #{ format(actual(model)) }"
    end
  end
end

RSpec::Matchers.define :validate do
  match do |graph|
    @validator = Refinery::Catalyst::Validation.new(graph).run!
    @validator.errors.empty?
  end

  failure_message_for_should do |graph|
    errors = @validator.errors.map do |model, messages|
      messages.map { |message| "  * #{ model.inspect } #{ message }" }
    end.flatten.join("\n")

    "Expected graph to validate, but had the following errors:\n\n#{ errors }"
  end

  failure_message_for_should_not do |graph|
    "Expected graph to fail validation, but it passed"
  end

  description do |*|
    'pass graph validation'
  end
end
