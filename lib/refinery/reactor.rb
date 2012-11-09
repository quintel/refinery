module Refinery
  # Runs one or more transformations ("Catalysts") on a graph, performing
  # changes to prepare it for export to YAML which is used by ETengine.
  class Reactor
    # Public: Creates a new Reactor used to make changes to the imported
    # Turbine graph.
    #
    # catalysts - An array of objects which respond to call. Each object is
    #             in turn given the graph.
    #
    # Returns a Reactor.
    def initialize(*catalysts)
      @catalysts = catalysts.flatten
    end

    # Public: Runs each catalyst in the Reactor on the given Turbine graph.
    # Note that changes are made directly to the given graph instance, not a
    # copy.
    #
    # graph - The Turbine::Graph to be modified.
    #
    # Returns the graph.
    def run(graph)
      @catalysts.each { |catalyst| catalyst.call(graph) }
      graph
    end
  end # Reactor
end # Refinery
