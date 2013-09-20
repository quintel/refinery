module Refinery::Strategies
  module Reversible
    # Methods which calculate a strategy from the child towards the parent.
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
