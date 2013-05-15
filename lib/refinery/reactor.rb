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
    # Don't assume that each catalyst will modify the given graph in place;
    # they may create and return a copy, or a different object entirely:
    #
    #   # Wrong!
    #   Reactor.new(...).run(graph)
    #
    #   # Correct!
    #   result = Reactor.new(...).run(graph)
    #
    # graph - The Turbine::Graph on which to run the catalysts.
    #
    # Returns the result of the final catalyst.
    def run(graph)
      @catalysts.reduce(graph) { |memo, catalyst| catalyst.call(memo) }
    end
  end # Reactor
end # Refinery
