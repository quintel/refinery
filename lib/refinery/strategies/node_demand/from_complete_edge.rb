module Refinery::Strategies
  module NodeDemand
    # Calculates the demand of a node when we know the demand of one of its
    # edges, the share of that edge, and the share of the slot.
    class FromCompleteEdge < FromEdges
      def calculable?(node)
        completed_edge(node)
      end

      def calculate(node)
        edge = completed_edge(node)
        edge.demand / share(edge) / slots(node).get(edge.label).share
      end

      #######
      private
      #######

      # Internal: Looks for an edge which has a demand and share, where we
      # also know the share of the slot.
      #
      # Returns an edge or nil.
      def completed_edge(node)
        suitable_slots = slots(node).select do |slot|
          slot.share && ! slot.share.zero?
        end

        suitable_slots.each do |slot|
          edge = slot.edges.detect do |edge|
            edge.demand && share(edge) && ! share(edge).zero?
          end

          return edge if edge
        end

        nil
      end
    end # FromCompleteEdge
  end # NodeDemand
end # Refinery::Strategies