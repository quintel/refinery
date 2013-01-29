module Refinery
  module Stub
    # Public: Creates a stub Turbine graph using the structure defined in
    # etsource#168.
    #
    # This is temporary and will eventually be replaced by parsing InputExcel
    # CSVs into a Turbine structure. However, this stub will be used, and
    # frequently added to, while adding new "catalyst" features.
    #
    # Returns a Turbine graph.
    def self.etsource_168
      graph = Turbine::Graph.new

      # Nodes
      # -----

      fd_gas            = graph.add(N :fd_gas)
      fd_hh_gas         = graph.add(N :fd_hh_gas)
      cooling           = graph.add(N :cooling)
      hot_water         = graph.add(N :hot_water)
      cooking           = graph.add(N :cooking)
      space_heating_gas = graph.add(N :space_heating_gas)
      gas_heater        = graph.add(N :gas_heater)
      combi_heater      = graph.add(N :combi_heater)
      gas_heat_pump     = graph.add(N :gas_heat_pump)
      gas_chp           = graph.add(N :gas_chp)
      ud_heating_hh     = graph.add(N :ud_heating_hh)
      fd_ind_gas        = graph.add(N :fd_ind_gas)
      burner            = graph.add(N :burner)
      ud_heating_ind    = graph.add(N :ud_heating_ind)

      # Node Properties
      # ---------------

      fd_hh_gas.set(:final_demand, 361.8)
      fd_ind_gas.set(:final_demand, 266.6)

      # Edges
      # -----

      fd_gas.connect_to(fd_hh_gas, :gas)
      fd_gas.connect_to(fd_ind_gas, :gas)

      fd_hh_gas.connect_to(cooling, :gas, parent_share: 0.0)
      fd_hh_gas.connect_to(hot_water, :gas, parent_share: 0.24)
      fd_hh_gas.connect_to(cooking, :gas, parent_share: 0.03)
      fd_hh_gas.connect_to(space_heating_gas, :gas, parent_share: 0.73)

      space_heating_gas.connect_to(gas_heater, :gas, parent_share: 0.1)
      space_heating_gas.connect_to(combi_heater, :gas, parent_share: 0.9)
      space_heating_gas.connect_to(gas_heat_pump, :gas, parent_share: 0.0)
      space_heating_gas.connect_to(gas_chp, :gas, parent_share: 0.0)

      gas_heater.connect_to(ud_heating_hh, :heat)
      combi_heater.connect_to(ud_heating_hh, :heat)
      gas_heat_pump.connect_to(ud_heating_hh, :heat)
      gas_chp.connect_to(ud_heating_hh, :heat)

      fd_ind_gas.connect_to(burner, :gas)
      burner.connect_to(ud_heating_ind, :heat)

      graph
    end

    # Public: Creates a stub Turbine graph using the structure defined in
    # etsource#179. This extends on the structure defined in etsource#168.
    #
    # Returns a Turbine graph.
    def self.etsource_179
      graph = self.etsource_168

      # Nodes
      # -----

      gas_chp                = graph.node(:gas_chp)

      elec_network           = graph.add(N :elec_network)
      locally_available_elec = graph.add(N :locally_available_elec)
      fd_elec                = graph.add(N :fd_elec)
      fd_hh_elec             = graph.add(N :fd_hh_elec)
      space_heating_elec     = graph.add(N :space_heating_elec)
      electric_heater        = graph.add(N :electric_heater)

      # Node Properties
      # ---------------

      fd_hh_elec.set(:final_demand, 100.0)

      # Edges
      # -----

      elec_network.connect_to(locally_available_elec, :electricity)
      locally_available_elec.connect_to(fd_elec, :electricity)
      fd_elec.connect_to(fd_hh_elec, :electricity)
      fd_hh_elec.connect_to(space_heating_elec, :electricity)
      space_heating_elec.connect_to(electric_heater, :electricity)
      electric_heater.connect_to(graph.node(:ud_heating_hh), :heat)

      gas_chp.connect_to(locally_available_elec, :electricity)

      graph.node(:combi_heater).in_edges.first.set(:parent_share, 0.5)
      gas_chp.in_edges.first.set(:parent_share, 0.4)

      # Gas CHP efficiencies
      gas_chp.slots.out(:heat).set(:share, 0.7)
      gas_chp.slots.out(:electricity).set(:share, 0.3)

      graph
    end

    # Internal: A shorthand way to create a new node with a +key+.
    #
    # Returns a Turbine node.
    def self.N(key)
      Node.new(key)
    end

    private_class_method :N

    # A class which builds a stub from the ETsource topology, using skeleton
    # data (final demand, slot conversion) extracted from a dataset.
    class ETsource
      LINK = /(?<type>\w) -->? \((?<carrier>[a-z_]+)\)-(?<source>[a-z0-9_]+)$/.freeze

      # Creates a new ETsource stub.
      #
      # path   - Path to the ETsource directory.
      # region - The region code to be used to load skeleton data.
      #
      # Returns an ETsource.
      def initialize(path, region)
        @path   = Pathname.new(path)
        @region = region
      end

      # Public: Creates the Turbine graph using data from ETsource.
      #
      # Return a Turbine::Graph.
      def graph
        Turbine::Graph.new.tap do |graph|
          create_nodes(graph)
          create_edges(graph)
          configure_nodes(graph)
          configure_slots(graph)
        end
      end

      #######
      private
      #######

      # Internal: The topology data defining the graph structure.
      #
      # Returns a hash of hashes, each value is a node.
      def topology
        @topology ||= begin
          raw = yaml(@path.join('topology/export.graph'))
          symbolize_keys(raw) { |value| symbolize_keys(value) }
        end
      end

      # Internal: The dataset data added to the graph structure.
      #
      # Returns a hash of hashes, each value information about a node or slot.
      def dataset
        @dataset ||= begin
          raw = {}

          @path.join("datasets/#{ @region }/graph").each_child do |filename|
            raw.merge!(yaml(filename))
          end

          raw
        end
      end

      # Internal: Given a graph, adds nodes from the topology.
      #
      # Returns nothing.
      def create_nodes(graph)
        topology.each do |key, data|
          graph.add(Node.new(key.to_sym, {
            use:                  data[:use],
            sector:               data[:sector],
            energy_balance_group: data[:energy_balance_group]
          }))
        end
      end

      # Internal: Given a graph, creates the edges between each node.
      #
      # Returns nothing.
      def create_edges(graph)
        topology.each do |key, data|
          data[:links] && data[:links].each do |link|
            info = link.match(LINK)

            # I'm temporarily ignoring coupling carrier since the slot
            # shares are completely FUBAR for Refinery's purposes.
            next if info[:carrier].to_sym == :coupling_carrier

            edge = graph.node(info[:source].to_sym).
              connect_to(graph.node(key), info[:carrier].to_sym)

            edge.set(:type, case info[:type]
              when 's' then :share
              when 'f' then :flexible
              when 'i' then :overflow
              when 'c' then :constant
              when 'd' then :dependent
            end)

            edge.set(:reversed, link.include?('<'))
          end
        end
      end

      # Internal: Uses region data to set up nodes with the data required to
      # perform a calculation.
      #
      # Returns nothing.
      def configure_nodes(graph)
        graph.nodes.each do |node|
          # Presently, final_demand is not actually stored in the ETsource
          # YAML files, so this is a temporary alternative:
          if node.key.to_s.include?('final_demand')
            node.set(
              :final_demand,
              dataset[node.key.to_s][:demand_expected_value])
          end
        end
      end

      # Internal: Uses region data to set slot conversions ("share").
      #
      # Returns nothing.
      def configure_slots(graph)
        graph.nodes.each do |node|
          node.slots.out.each do |slot|
            configure_slot(slot, dataset["(#{ slot.carrier })-#{ node.key }"])
          end

          node.slots.in.each do |slot|
            configure_slot(slot, dataset["#{ node.key }-(#{ slot.carrier })"])
          end

          configure_loss_slot(node, :out) if dataset["(loss)-#{ node.key }"]
          configure_loss_slot(node, :in)  if dataset["#{ node.key }-(loss)"]
        end
      end

      # Internal: Given a slot and the relevant data from the dataset, sets
      # the slots share. Does nothing if the dataset has no information for
      # this slot.
      #
      # Returns nothing.
      def configure_slot(slot, data)
        if data && data['conversion']
          slot.set(:share, data['conversion'])
        end
      end

      # Internal: If a node is expected to have a loss slot, this sets the
      # share of the slot by filling the whatever slot share is not fulfilled
      # by the siblings. For example, if the node has a single other slot with
      # a share of 0.8, the loss slot will be assigned 0.2.
      #
      # Returns nothing.
      def configure_loss_slot(node, direction)
        slots = node.slots.public_send(direction)
        loss  = slots.include?(:loss) ? slots.get(:loss) : slots.add(:loss)

        share = 1.0 - slots.sum do |slot|
          slot.carrier == :loss ? 0.0 : slot.get(:share)
        end

        loss.set(:share, share < 0 ? 0.0 : share)
      end

      # Internal: Given a hash, returns a new hash with each of its keys
      # changed to be a symbol. An optional block can be provided which can
      # be used to further manipulate each value.
      #
      # Returns a hash.
      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), symbolized|
          symbolized[key.to_sym] = block_given? ? yield(value) : value
        end
      end

      # Internal: Loads a YAML file from ETsource.
      #
      # path - The absolute path to the file.
      #
      # Returns the parsed data.
      def yaml(path)
        old_yamler, YAML::ENGINE.yamler = YAML::ENGINE.yamler, 'syck'
        YAML.load_file(@path.join('topology/export.graph'))
      ensure
        YAML::ENGINE.yamler = old_yamler
      end
    end # ETsource

  end # Stub
end # Refinery
