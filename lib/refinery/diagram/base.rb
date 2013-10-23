module Refinery
  module Diagram
    class Base

      # Public: Creates a new Diagram which creates a PNG showing the nodes
      # and their edges. On the graph is also the share assigned to each edge,
      # and the demand calculated for each node.
      #
      # graph - The graph to be converted to a PNG.
      #
      # Returns a Diagram
      def initialize(graph, options = {})
        @graph      = graph
        @diagram    = GraphViz.new(:G, rankdir: :RL)

        @gv_nodes   = {}
        @clusters   = {}

        @filter_by  = options[:filter_by]  || ->(*) { true }
        @cluster_by = options[:cluster_by] || ->(*) { nil }

        @demand_label = options[:format_demand] || ->(value) { value }

        @clusters[nil] = @diagram
      end

      # Public: Draws the PNG diagram to a +path+ on disk.
      #
      # path - The file path to which the PNG will be written.
      #
      # Returns nothing.
      def draw_to(path)
        edges.each do |edge|
          supplier = add_node(edge.from)
          consumer = add_node(edge.to)

          add_to = if cluster_for(edge.from) == cluster_for(edge.to)
            # If both edges are in the same cluster, constrain the edges to
            # it's boundary.
            cluster_for(edge.from)
          else
            @diagram
          end

          add_to.add_edges(supplier, consumer, edge_options(edge))
        end

        @diagram.output(png: path)
      end

      #######
      private
      #######

      # Graph Organisation ---------------------------------------------------

      # Internal: The edges which are to be included in the diagram.
      #
      # Returns an array of edges.
      def edges
        @graph.nodes.map do |node|
          node.out_edges.select(&@filter_by).to_a
        end.flatten
      end

      # Internal: Given a node from the graph, adds it to the diagram. Does
      # nothing if the node has already been added.
      #
      # Returns nothing.
      def add_node(node)
        @gv_nodes[ node.key ] ||=
          cluster_for(node).add_nodes(node.key.to_s, node_options(node))
      end

      # Internal: Retrieves, or creates, the cluster to which the node
      # belongs.
      #
      # Returns a Graphviz graph.
      def cluster_for(node)
        cluster_name = @cluster_by.call(node)

        @clusters[ cluster_name ] ||=
          @diagram.add_graph("cluster_#{ cluster_name }", color: 'lightgrey')
      end

      # Element Options ------------------------------------------------------

      # Internal: The hash of options for formatting a node.
      #
      # Returns a hash.
      def node_options(node)
        label = node_label(node)

        NODE_OPTIONS.merge(
          label:     label,
          color:     color(:black),
          fontcolor: color(:black))
      end

      # Internal: The hash of options for formatting an edge.
      #
      # Returns a hash.
      def edge_options(edge)
        style = case edge.get(:type)
          when :overflow then :dashed
          when :flexible then :dotted
          else                :solid
        end

        EDGE_OPTIONS.merge(
          style:     style,
          label:     edge_label(edge),
          fontcolor: color(:grey),
          color:     color(EDGE_COLORS[edge.label]))
      end

      # Labels ---------------------------------------------------------------

      # Internal: The label to be shown next to an edge. Includes the share
      # value which was calculated.
      #
      # Returns a string.
      def edge_label(edge)
        shares = [ "&lt;- #{ format_number(edge.parent_share || '?') }",
                   "#{ format_number(edge.child_share || '?') } &lt;-" ]

        shares.map! do |share|
          "<font color='#{ color(:lightgrey) }'>#{ share }</font>"
        end

        "<#{ shares[1] } (#{ format_demand(edge.demand) }) #{ shares[0] }>"
      end

      # Internal: The label shown inside the node. Includes the node key and
      # the demand value which was calculated.
      #
      # Returns a string.
      def node_label(node)
        key_attrs = node.get(:final_demand) ? ' face="Helvetica-Bold"' : ''
        base      = %(<<font#{ key_attrs }>#{ node.key }</font> )
        attrs     = 'point-size="9" face="Helvetica-Bold"'

        base + if node.demand.nil?
          %(<font #{ attrs } color="#{ color(:red) }">?!</font>>)
        else
          %(<font #{ attrs } color="#8c8c8c">) +
            %(#{ format_demand(node.demand) }</font>>)
        end
      end

      # Internal: The color string for the given color name. Optionally with
      # semi-transparency.
      #
      # Returns a string.
      def color(name, transparent = false)
        transparent && "#{ COLORS[name] }5f" || COLORS[name]
      end

      # Internal: Given a number (typically a Rational) formats it nicely for
      # the diagram.
      #
      # Returns a string.
      def format_number(number)
        return ''     if     number.nil?
        return number unless number.is_a?(Numeric)

        formatted = '%.6g' % number
        formatted = formatted.match(/\./) ? formatted : "#{ formatted }.0"

        # Add comma delimiters.
        parts = formatted.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
        parts.join('.')
      end

      # Internal: A variant of +format_number+ which will format a demand
      # value for use in a label.
      #
      # Returns a string.
      def format_demand(value)
        value ? format_number(@demand_label.call(value)) : '-'
      end
    end # Base
  end # Diagram
end # Refinery
