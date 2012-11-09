module Refinery
  module Catalyst

    # Sets a "share" of 1.0 on any edge where a share isn't already set, and
    # when the edge is the only "out" edge of it's "out" node.
    FillSharelessEdges = ->(graph) do
      graph.nodes.each do |node|
        if node.out_edges.take(2).one?
          edge = node.out_edges.first
          edge.set(:share, 1.0) if edge.get(:share).nil?
        end
      end
    end

  end # Catalyst
end # Refinery
