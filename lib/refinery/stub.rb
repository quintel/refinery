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

      fd_hh_gas.connect_to(cooling, :gas, share: 0.0)
      fd_hh_gas.connect_to(hot_water, :gas, share: 0.24)
      fd_hh_gas.connect_to(cooking, :gas, share: 0.03)
      fd_hh_gas.connect_to(space_heating_gas, :gas, share: 0.73)

      space_heating_gas.connect_to(gas_heater, :gas, share: 0.1)
      space_heating_gas.connect_to(combi_heater, :gas, share: 0.9)
      space_heating_gas.connect_to(gas_heat_pump, :gas, share: 0.0)
      space_heating_gas.connect_to(gas_chp, :gas, share: 0.0)

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

      elec_network           = graph.add(N :elec_network)
      locally_available_elec = graph.add(N :locally_available_elec)
      fd_elec                = graph.add(N :fd_elec)
      fd_hh_elec             = graph.add(N :fd_hh_elec)
      space_heating_elec     = graph.add(N :space_heating_elec)
      space_heating_chp      = graph.add(N :space_heating_chp)

      # Node Properties
      # ---------------

      fd_elec.set(:final_demand, 100)

      # Edges
      # -----

      elec_network.connect_to(locally_available_elec, :electricity)
      locally_available_elec.connect_to(fd_elec, :electricity)
      fd_elec.connect_to(fd_hh_elec, :electricity)
      fd_hh_elec.connect_to(space_heating_elec, :electricity)
      space_heating_elec.connect_to(graph.node(:ud_heating_hh), :heat)

      graph.node(:space_heating_gas).connect_to(space_heating_chp, :gas)
      space_heating_chp.connect_to(locally_available_elec, :electricity)
      space_heating_chp.connect_to(graph.node(:ud_heating_hh), :heat)

      graph
    end

    # Internal: A shorthand way to create a new node with a +key+.
    #
    # Returns a Turbine node.
    def self.N(key)
      Turbine::Node.new(key)
    end

    private_class_method :N

  end # Stub
end # Refinery
