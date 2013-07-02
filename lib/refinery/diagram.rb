module Refinery
  class Diagram
    # Default options used for all nodes.
    NODE_OPTIONS = { fontname: 'Helvetica', fontsize: 11, shape: 'rect' }

    # Default options used for all edges.
    EDGE_OPTIONS = { fontname: 'Helvetica Bold', fontsize: 9 }

    # General colors.
    COLORS = {
      black:     '#404040',
      blue:      '#4169e1',
      brown:     '#8b4513',
      darkpink:  '#cd6090',
      grey:      '#888888',
      lightgrey: '#bbbbbb',
      olive:     '#6b8e23',
      orange:    '#cd8500',
      purple:    '#9370db',
      pink:      '#ffc0cb',
      red:       '#ee4000'
    }

    # Colors assigned to edges depending on their label.
    EDGE_COLORS = {
      algae_diesel:              :olive,
      ambient_cold:              :orange,
      ambient_heat:              :orange,
      biodiesel:                 :olive,
      biogas:                    :olive,
      biogenic_waste:            :olive,
      bio_ethanol:               :olive,
      bio_oil:                   :olive,
      bio_residues_for_firing:   :olive,
      car_kms:                   :purple,
      coal:                      :black,
      coal_gas:                  :black,
      cokes:                     :black,
      compressed_network_gas:    :grey,
      cooling:                   :purple,
      coupling_carrier:          :pink,
      corn:                      :olive,
      crude_oil:                 :brown,
      diesel:                    :brown,
      diesel_mix:                :brown,
      electricity:               :blue,
      gas:                       :grey,
      gasoline:                  :brown,
      gasoline_mix:              :brown,
      gas_power_fuelmix:         :grey,
      greengas:                  :olive,
      heat:                      :purple,
      heavy_fuel_oil:            :brown,
      hot_water:                 :purple,
      imported_electricity:      :blue,
      imported_steam_hot_water:  :darkpink,
      kerosene:                  :brown,
      light:                     :purple,
      lignite:                   :black,
      lng:                       :brown,
      loss:                      :orange,
      lpg:                       :brown,
      manure:                    :olive,
      natural_gas:               :grey,
      non_biogenic_waste:        :black,
      not_defined:               :orange,
      solar_radiation:           :orange,
      solar_thermal:             :olive,
      steam_hot_water:           :darkpink,
      torrified_biomass_pellets: :olive,
      truck_kms:                 :purple,
      uranium_oxide:             :orange,
      useable_heat:              :purple,
      waste_mix:                 :black,
      water:                     :orange,
      wind:                      :orange,
      wood:                      :olive,
      wood_pellets:              :olive
    }

    EDGE_COLORS.default = :black

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
      diagram = GraphViz.new(:G, type: :digraph, rankdir: :RL)

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
        color:     color(:black),
        fontcolor: color(:black))
    end

    # Internal: The hash of options for formatting an edge.
    #
    # Returns a hash.
    def edge_options(edge)
      EDGE_OPTIONS.merge(
        style:     edge.get(:type) == :overflow ? :dashed : :solid,
        label:     edge_label(edge),
        fontcolor: color(:grey),
        color:     color(EDGE_COLORS[edge.label]))
    end

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

      demand = edge.demand ? format_number(edge.demand) : '-'

      "<#{ shares[1] } (#{ demand }) #{ shares[0] }>"
    end

    # Internal: The label shown inside the node. Includes the node key and the
    # demand value which was calculated.
    #
    # Returns a string.
    def node_label(node)
      key_attrs = node.get(:final_demand) ? ' face="Helvetica Bold"' : ''
      base      = %(<<font#{ key_attrs }>#{ node.key }</font> )
      attrs     = 'point-size="9" face="Helvetica Bold"'

      base + if node.demand.nil?
        %(<font #{ attrs } color="#{ color(:red) }">?!</font>>)
      else
        %(<font #{ attrs } color="#8c8c8c">) +
          %(#{ format_number(node.demand) }</font>>)
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

    # A diagram which allows you to set some nodes and labels to be
    # semi-transparent.
    class Recolored < Diagram
      private

      def recolor_label(label, transparent)
        transparent && label.gsub(/(color=['"]#.{6})/, '\120') || label
      end

      def recolor_options(options, transparent)
        return options unless transparent

        options[:fontcolor] = "#{ options[:fontcolor] }20"
        options[:color]     = "#{ options[:color] }20"
        options
      end
    end

    # A diagram which shows the incalculable nodes and edges normally, and all
    # other elements mostly transparent.
    class Incalculable < Recolored
      #######
      private
      #######

      def edge_options(edge)
        recolor_options(super, edge.demand)
      end

      def node_options(node)
        recolor_options(super, node.demand)
      end

      def edge_label(edge)
        recolor_label(super, edge.demand)
      end

      def node_label(node)
        recolor_label(super, node.demand)
      end
    end # Incalculable

    # A diagram which shows the calculable nodes normally, fading the
    # incalculable elements into the background.
    class Calculable < Incalculable
      #######
      private
      #######

      def recolor_label(label, transparent)
        super(label, ! transparent)
      end

      def recolor_options(label, transparent)
        super(label, ! transparent)
      end
    end # Calculable

    # A specialised "Calculable" diagram which also shows edges which had a
    # parent or child share defined by the user.
    class InitialValues < Recolored
      #######
      private
      #######

      def edge_options(edge)
        recolor_options(super, no_initial_share?(edge))
      end

      def node_options(node)
        recolor_options(super, ! node.get(:demand))
      end

      def edge_label(edge)
        if no_initial_share?(edge)
          recolor_label('?!', true)
        else
          "<<font face='Helvetica' color='#{ color(:lightgrey) }'> " \
            "#{ format_number(edge.get(:parent_share) || '-') }, " \
            "#{ format_number(edge.get(:child_share) || '-') }</font>>"
        end
      end

      def node_label(node)
        recolor_label(super, ! node.get(:demand))
      end

      def no_initial_share?(edge)
        edge.get(:parent_share).nil? && edge.get(:child_share).nil?
      end
    end # InitialValues

    # A diagram which, draws a specified edge or node with a really big border
    # so that it can be more easily seen.
    class Focused < Diagram
      def initialize(graph, focused_element)
        super(graph)
        @focused_element = focused_element
      end

      #######
      private
      #######

      def edge_options(edge)
        super.merge(penwidth: edge == @focused_element ? 4.0 : 1.0)
      end

      def node_options(node)
        super.merge(penwidth: node == @focused_element ? 3.0 : 1.0)
      end
    end # Focused
  end # Diagram
end # Refinery
