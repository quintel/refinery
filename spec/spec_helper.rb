require 'rspec'
require 'support/coverage' if ENV['COVERAGE']
require 'refinery'

Dir['./spec/{support,factories}/**/*.rb'].map do |file|
  require file unless file.end_with?('coverage.rb')
end

RSpec.configure do |config|
  # Use only the new "expect" syntax.
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  # Tries to find examples / groups with the focus tag, and runs them. If no
  # examples are focues, run everything. Prevents the need to specify
  # `--tag focus` when you only want to run certain examples.
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # Allow adding examples to a filter group with only a symbol.
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Enable integration helpers when required.
  config.include Refinery::Spec::Integration, type: :integration,
    example_group: { file_path: %r{spec\/integration} }
end
