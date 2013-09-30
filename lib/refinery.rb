require 'bundler' ; Bundler.setup
require 'terminal-table'
require 'graphviz'
require 'turbine'

module Refinery; end

require 'refinery/strategies/reversible'
require 'refinery/strategies/reversible/forwards'
require 'refinery/strategies/reversible/reversed'
require 'refinery/strategies/node_demand/from_complete_edge'
require 'refinery/strategies/node_demand/from_complete_slot'
require 'refinery/strategies/node_demand/from_partial_slot'
require 'refinery/strategies/edge_demand/by_share'
require 'refinery/strategies/edge_demand/fill_remaining'
require 'refinery/strategies/edge_demand/fill_remaining_across_slots'
require 'refinery/strategies/edge_demand/solo'
require 'refinery/strategies/edge_demand/overflow'
require 'refinery/strategies/edge_demand/flexible'

require 'refinery/precise_properties'
require 'refinery/calculators/base'
require 'refinery/calculators/edge_demand'
require 'refinery/calculators/node_demand'
require 'refinery/catalyst/calculators'
require 'refinery/catalyst/visual_calculator'
require 'refinery/catalyst/convert_final_demand'
require 'refinery/catalyst/from_turbine'
require 'refinery/catalyst/validation'
require 'refinery/core_ext/enumerable'
require 'refinery/diagram'
require 'refinery/diagram/base'
require 'refinery/diagram/incalculable'
require 'refinery/diagram/calculable'
require 'refinery/diagram/initial_values'
require 'refinery/diagram/focused'
require 'refinery/edge'
require 'refinery/errors'
require 'refinery/graph_debugger'
require 'refinery/node'
require 'refinery/slot'
require 'refinery/slot_collection'
require 'refinery/util'
