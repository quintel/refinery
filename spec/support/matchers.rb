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

  def actual(model)
    @fetcher.nil? ? model.public_send(@attribute) : @fetcher.call(model)
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
      "expected #{ model } to have #{ attribute } #{ @expectation }, but " \
      "it was #{ actual(model).inspect }"
    else
      "expected #{ model } to have #{ attribute } calculated"
    end
  end

  failure_message_for_should_not do |model|
    if @expectation
      "expected #{ model } to not have #{ attribute } of #{ @expectation }"
    else
      "expected #{ model } to not have #{ attribute } calculated"
    end
  end
end

