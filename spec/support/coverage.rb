if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter('/spec/')

    # Tools whose output is PNG diagrams to be read by humans; hard to test
    # these fully.
    add_filter('/lib/refinery/diagram')
    add_filter('/lib/refinery/graph_debugger')
    add_filter('/lib/refinery/catalyst/visual_calculator')
  end
end
