module Refinery::Strategies
  module Reversible
    # Runs a strategy in the direction in which it is written. i.e., each call
    # to +in_edges+ really does call +in_edges+, +parent_share+ fetches the
    # parent share, etc.
    #
    # Since Reversible strategies are written assuming that we know something
    # about the parent (either a in/from node, or in_edges), mixing in Forwards
    # has the effect of calculating parent-to-child.
    module Forwards
      def forwards?
        true
      end

      def child_share(edge)
        edge.child_share
      end

      def parent_share(edge)
        edge.parent_share
      end

      def child_slot(edge)
        edge.to.slots.in(edge.label)
      end

      def parent_slot(edge)
        edge.from.slots.out(edge.label)
      end

      def to(thing)
        thing.to
      end

      def from(thing)
        thing.from
      end

      def in_slots(node, *args)
        node.slots.in(*args)
      end

      def out_slots(node, *args)
        node.slots.out(*args)
      end

      def in_edges(node, *args)
        node.in_edges(*args)
      end

      def out_edges(node, *args)
        node.out_edges(*args)
      end

      def output_of(node, carrier)
        node.output_of(carrier)
      end

      def demand_for(node, carrier)
        node.demand_for(carrier)
      end
    end # Forwards
  end # Reversible
end # Refinery::Strategies
