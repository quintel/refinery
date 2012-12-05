module Refinery
  module Catalyst
    # Public: Given a graph, finds any nodes which have a :final_demand
    # attribute, and duplicates it's value as :expected_demand or
    # :preset_demand.
    #
    # graph - The graph.
    #
    # Returns nothing.
    ConvertFinalDemand = ->(graph) do
      graph.nodes.each do |node|
        if demand = node.get(:final_demand)
          attribute = node.out_edges.any? ? :expected_demand : :preset_demand
          node.set(attribute, demand)
        end
      end
    end # ConvertFinalDemand
  end # Catalyst
end # Refinery
