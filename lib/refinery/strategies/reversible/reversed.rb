module Refinery::Strategies
  module Reversible
    # Methods which calculate a strategy from the parent towards the child.
    module Reversed
      def forwards?
        false
      end

      def child_share(edge)
        edge.parent_share
      end

      def parent_share(edge)
        edge.child_share
      end

      def child_slot(edge)
        edge.from.slots.out(edge.label)
      end

      def parent_slot(edge)
        edge.to.slots.in(edge.label)
      end

      def to(thing)
        thing.from
      end

      def from(thing)
        thing.to
      end

      def in_slots(node, *args)
        node.slots.out(*args)
      end

      def out_slots(node, *args)
        node.slots.in(*args)
      end

      def in_edges(node, *args)
        node.out_edges(*args)
      end

      def out_edges(node, *args)
        node.in_edges(*args)
      end

      def output_of(node, carrier)
        node.demand_for(carrier)
      end

      def demand_for(node, carrier)
        node.output_of(carrier)
      end
    end # Backwards
  end # Reversible
end # Refinery::Strategies
