module Refinery
  module Catalyst
    # Given a graph, assigns input and output slots to each node depending
    # on the edges which exist.
    #
    # You can skip assignment of some slots (for example, if you want to set
    # a custom "share" on a slot) by prematurely assigning it:
    #
    #   node.set(:slots) = {
    #     out: { gas: Slot.new(node, :out, :gas, share: 0.7) }
    #   }
    #
    # In this case, it'll skip assigning an output slot for gas, and use the
    # one you provided instead.
    module AssignSlots
      # Public: Assigns slots to each node in the given +graph+.
      #
      # Returns nothing.
      def self.call(graph)
        graph.nodes.each do |node|
          assign_slots(node, :in)
          assign_slots(node, :out)
        end
      end

      # Internal: Creates a hash containing the slots for a +node+ in the
      # requested +direction+.
      #
      # node      - The node whose slots are to be created.
      # direction - :in or :out.
      #
      # Returns a hash in the form {Symbol => Slot}.
      def self.assign_slots(node, direction)
        carriers   = node.edges(direction).map(&:label).uniq
        collection = node.slots.public_send(direction)

        carriers.each_with_object({}) do |label, slots|
          collection.add(label) unless collection.include?(label)
        end
      end

      private_class_method :assign_slots
    end # AssignSlots
  end # Catalyst
end # Refinery
