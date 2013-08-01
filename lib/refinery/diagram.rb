module Refinery
  module Diagram
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

    # Included in a diagram, provides the ability to change the transparency
    # of nodes, edges, or labels.
    module Transparency
      def recolor_label(label, transparent)
        transparent && label.gsub(/(color=['"]#.{6})/, '\120') || label
      end

      def recolor_options(options, transparent)
        return options unless transparent

        options[:fontcolor] = "#{ options[:fontcolor] }20"
        options[:color]     = "#{ options[:color] }20"
        options
      end
    end # Transparency

  end # Diagram
end # Refinery
