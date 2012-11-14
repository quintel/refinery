guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| %W(spec/#{m[1]}_spec.rb spec/integration) }
  watch('spec/spec_helper.rb') { "spec" }
  watch(%r{^spec/factories/.*}) { "spec" }
end
