module Refinery
  module Catalyst
    # Public: Given a graph, finds any nodes which have a :final_demand
    # attribute, and duplicates it's value as :demand.
    #
    # graph - The graph.
    #
    # Returns nothing.
    ConvertFinalDemand = ->(graph) do
      graph.nodes.each do |node|
        if demand = node.get(:final_demand)
          node.set(:demand, demand)
        end
      end
    end # ConvertFinalDemand
  end # Catalyst
end # Refinery
