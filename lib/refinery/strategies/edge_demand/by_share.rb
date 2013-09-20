module Refinery::Strategies
  module EdgeDemand
    # A strategy which calculates the demand of an edge when we know the
    # output of the parent, and also have a parent share defined on the edge.
    class ByShare
      include Reversible

      def calculable?(edge)
        output_of(from(edge), edge.label) && parent_share(edge)
      end

      def calculate(edge)
        output_of(from(edge), edge.label) * parent_share(edge)
      end

      # Public: The strategy as a string.
      #
      # Returns a string.
      def to_s
        "#{ self.class.name } (#{ reversed? ? :child_share : :parent_share })"
      end
    end
  end # EdgeDemand
end # Refinery::Strategies
