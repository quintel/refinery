require 'bundler' ; Bundler.setup
require 'terminal-table'
require 'graphviz'
require 'turbine'

module Refinery; end

require 'refinery/strategies/demand/fill_remaining'
require 'refinery/strategies/demand/from_children'
require 'refinery/strategies/demand/from_parents'
require 'refinery/strategies/demand/only_child'
require 'refinery/strategies/edge_demand/fill_remaining'
require 'refinery/strategies/edge_demand/fill_remaining_from_parent'
require 'refinery/strategies/edge_demand/from_demand'
require 'refinery/strategies/edge_demand/only_child'
require 'refinery/strategies/edge_demand/parent_share'
require 'refinery/strategies/edge_demand/child_share'
require 'refinery/strategies/edge_demand/single_parent'

require 'refinery/precise_properties'
require 'refinery/calculators/base'
require 'refinery/calculators/edge_demand'
require 'refinery/calculators/node_demand'
require 'refinery/catalyst/calculators'
require 'refinery/catalyst/convert_final_demand'
require 'refinery/catalyst/validation'
require 'refinery/core_ext/enumerable'
require 'refinery/diagram'
require 'refinery/edge'
require 'refinery/errors'
require 'refinery/exporter'
require 'refinery/graph_debugger'
require 'refinery/node'
require 'refinery/reactor'
require 'refinery/slot'
require 'refinery/slots_collection'
require 'refinery/stub'

module Refinery
  module_function

  # Public: Loads the source files into a Turbine graph.
  #
  # Presently this creates a stub graph as documented in etsource#168, but in
  # the future will load CSVs output by InputExcel.
  #
  # path - Path to the source files on disk. Currently unused.
  #
  # Returns a Turbine::Graph.
  def load(path = nil)
    Stub.etsource_168
  end
end
