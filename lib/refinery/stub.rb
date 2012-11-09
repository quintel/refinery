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
    def self.create
      graph = Turbine::Graph.new

      # Nodes
      # -----

      fd_gas         = graph.add(Turbine::Node.new(:fd_gas))
      fd_hh_gas      = graph.add(Turbine::Node.new(:fd_hh_gas))
      cooling        = graph.add(Turbine::Node.new(:cooling))
      hot_water      = graph.add(Turbine::Node.new(:hot_water))
      cooking        = graph.add(Turbine::Node.new(:cooking))
      space_heating  = graph.add(Turbine::Node.new(:space_heating))
      gas_heater     = graph.add(Turbine::Node.new(:gas_heater))
      combi_heater   = graph.add(Turbine::Node.new(:combi_heater))
      gas_heat_pump  = graph.add(Turbine::Node.new(:gas_heat_pump))
      gas_chp        = graph.add(Turbine::Node.new(:gas_chp))
      ud_heating_hh  = graph.add(Turbine::Node.new(:ud_heating_hh))
      fd_ind_gas     = graph.add(Turbine::Node.new(:fd_ind_gas))
      burner         = graph.add(Turbine::Node.new(:burner))
      ud_heating_ind = graph.add(Turbine::Node.new(:ud_heating_ind))

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
      fd_hh_gas.connect_to(space_heating, :gas, share: 0.73)

      space_heating.connect_to(gas_heater, :gas, share: 0.1)
      space_heating.connect_to(combi_heater, :gas, share: 0.9)
      space_heating.connect_to(gas_heat_pump, :gas, share: 0.0)
      space_heating.connect_to(gas_chp, :gas, share: 0.0)

      gas_heater.connect_to(ud_heating_hh, :gas)
      combi_heater.connect_to(ud_heating_hh, :gas)
      gas_heat_pump.connect_to(ud_heating_hh, :gas)
      gas_chp.connect_to(ud_heating_hh, :gas)

      fd_ind_gas.connect_to(burner, :gas)
      burner.connect_to(ud_heating_ind, :gas)

      graph
    end
  end # Stub
end # Refinery
