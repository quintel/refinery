require 'bundler' ; Bundler.setup
require 'graphviz'
require 'turbine'

require 'refinery/catalyst/calculators'
require 'refinery/catalyst/convert_final_demand'
require 'refinery/strategies/demand/from_children'
require 'refinery/strategies/demand/from_parents'
require 'refinery/strategies/share/solo'
require 'refinery/strategies/share/fill_remaining'
require 'refinery/strategies/share/infer_from_child'
require 'refinery/strategies/share/solo'
require 'refinery/demand/calculator'
require 'refinery/demand/edge_share_calculator'
require 'refinery/demand/node_demand_calculator'
require 'refinery/diagram'
require 'refinery/errors'
require 'refinery/exporter'
require 'refinery/reactor'
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
