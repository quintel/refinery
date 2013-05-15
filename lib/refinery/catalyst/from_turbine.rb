module Refinery
  module Catalyst
    # Plugs into Refinery::Reactor to convert an ordinary Turbine graph to a
    # Refinery graph which can be used to complete the demand and share
    # calculations.
    FromTurbine = ->(original) do
      refinery = Turbine::Graph.new

      # For each node in the original graph, we add a Refinery::Node to the
      # new graph.
      original.nodes.each do |node|
        refinery.add(::Refinery::Node.new(node.key, node.properties))
      end

      # Reconnect the edges.
      original.nodes.each do |node|
        node.out_edges.each do |edge|
          parent = refinery.node(node.key)
          child  = refinery.node(edge.child.key)

          parent.connect_to(child, edge.label, edge.properties)
        end
      end

      refinery
    end # FromTurbine
  end # Catalyst
end # Refinery
