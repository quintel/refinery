module Refinery
  module Catalyst
    # Public: Given a graph which has demands for all nodes and edges,
    # calculates the share value of each edge and sets it as the :share
    # attribute.
    #
    # graph - The graph.
    #
    # Returns nothing.
    CalculateEdgeShares = ->(graph) do
      graph.nodes.each do |node|
        node.in_edges.reject { |edge| edge.get(:share) }.each do |edge|
          share =
            if edge.to.slots.in(edge.label).edges.length == 1
              1.0
            elsif edge.demand.zero?
              0.0
            else
              edge.demand / node.slots.in(edge.label).demand
            end

          edge.set(:share, share)
        end
      end
    end # CalculateEdgeShares
  end # Catalyst
end # Refinery
