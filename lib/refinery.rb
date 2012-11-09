require 'bundler' ; Bundler.setup
require 'turbine'

require 'refinery/catalyst/fill_shareless_edges'
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
    Stub.create
  end
end
