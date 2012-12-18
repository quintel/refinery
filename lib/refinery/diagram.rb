module Refinery
  class Diagram
    # Default options used for all nodes.
    NODE_OPTIONS = { fontname: 'Helvetica', fontsize: 11, shape: 'rect' }

    # Default options used for all edges.
    EDGE_OPTIONS = { fontname: 'Helvetica Bold', fontsize: 9 }

    # Colors assigned to edges depending on their label.
    EDGE_COLORS = { gas: :gray55, electricity: :orange3, heat: :purple }

    # Public: Creates a new Diagrap which creates a PNG showing the nodes and
    # their edges. On the graph is also the share assigned to each edge, and
    # the demand calculated for each node.
    #
    # graph - The graph to be converted to a PNG.
    #
    # Returns a Diagram.
    def initialize(graph)
      @graph = graph

      # Holds each GraphViz node.
      @nodes = {}
    end

    # Public: Draws the PNG diagram to a +path+ on disk.
    #
    # path - The file path to which the PNG will be written.
    #
    # Returns nothing.
    def draw_to(path)
      # Create a new graph
      diagram = GraphViz.new(:G, type: :digraph)

      # Create two nodes
      @graph.nodes.each do |node|
        @nodes[node.key] = diagram.add_nodes(
          node.key.to_s, node_options(node))
      end

      # Create an edge between the two nodes
      @graph.nodes.each do |node|
        node.out_edges.each do |edge|
          diagram.add_edges(
            @nodes[edge.from.key], @nodes[edge.to.key], edge_options(edge))
        end
      end

      # Generate output image
      diagram.output(png: path)
    end

    #######
    private
    #######

    # Internal: The hash of options for formatting a node.
    #
    # Returns a hash.
    def node_options(node)
      label = node_label(node)

      NODE_OPTIONS.merge(
        label:     label,
        color:     label.match(/\?!/) ? :red : :black,
        fontcolor: label.match(/\?!/) ? :red : :black)
    end

    # Internal: The hash of options for formatting an edge.
    #
    # Returns a hash.
    def edge_options(edge)
      EDGE_OPTIONS.merge(
        label:     edge_label(edge),
        fontcolor: edge.get(:share) ? :gray55 : :red,
        color:     edge.get(:share) ? EDGE_COLORS[edge.label] : :red)
    end

    # Internal: The label to be shown next to an edge. Includes the share
    # value which was calculated.
    #
    # Returns a string.
    def edge_label(edge)
      if share = edge.get(:share)
        flow = edge.from.demand
        flow = flow ? " <font color='#bbbbbb'>(#{ (flow * share).round(1) })</font>" : ''

        "<<font> #{ edge.get(:share).round(5) }#{ flow }</font>>"
      else
        '?!'
      end
    end

    # Internal: The label shown inside the node. Includes the node key and the
    # demand value which was calculated.
    #
    # Returns a string.
    def node_label(node)
      base   = %(<<font>#{ node.key }</font> )
      attrs  = 'point-size="9" face="Helvetica Bold"'

      base + if node.demand.nil?
        %(<font #{ attrs } color="red">?!</font>>)
      else
        %(<font #{ attrs } color="#8c8c8c">#{ node.demand.round(5) }</font>>)
      end
    end
  end # Diagram
end # Refinery
