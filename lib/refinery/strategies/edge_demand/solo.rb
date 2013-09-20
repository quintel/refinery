module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge, when the slot to
    # which it belongs contains no other edges.
    class Solo
      include Reversible

      def calculable?(edge)
        output_of(from(edge), edge.label) && only_edge?(edge)
      end

      def calculate(edge)
        output_of(from(edge), edge.label)
      end

      #######
      private
      #######

      def only_edge?(edge)
        if forwards?
          # When calculating from parent-to-child, it is acceptable for the
          # parent node to have an overflow edge which we ignore.
          out_edges(from(edge), edge.label).reject do |other|
            other.get(:type) == :overflow
          end.one?
        else
          out_edges(from(edge), edge.label).one?
        end
      end
    end # Solo
  end # EdgeDemand
end # Refinery::Strategies
