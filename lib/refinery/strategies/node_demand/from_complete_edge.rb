module Refinery::Strategies
  module NodeDemand
    # Calculates the demand of a node when we know the demand of one of its
    # edges, the share of that edge, and the share of the slot.
    class FromCompleteEdge
      include Reversible

      def calculable?(node)
        completed_edge(node)
      end

      def calculate(node)
        edge = completed_edge(node)
        edge.demand / child_share(edge) / in_slots(node, edge.label).share
      end

      private

      # Internal: Looks for an edge which has a demand and share, where we
      # also know the share of the slot.
      #
      # Returns an edge or nil.
      def completed_edge(node)
        suitable_slots = in_slots(node).reject do |slot|
          slot.share.nil? || slot.share.zero?
        end

        suitable_slots.each do |slot|
          found = slot.edges.detect do |edge|
            edge.demand && (share = child_share(edge)) && ! share.zero?
          end

          return found if found
        end

        nil
      end
    end # FromCompleteEdge
  end # NodeDemand
end # Refinery::Strategies
