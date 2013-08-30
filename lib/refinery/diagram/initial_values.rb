module Refinery
  module Diagram
    class InitialValues < Base
      include Transparency

      #######
      private
      #######

      def edge_options(edge)
        recolor_options(super, no_initial_share?(edge))
      end

      def node_options(node)
        recolor_options(super, ! node.get(:demand))
      end

      def edge_label(edge)
        if no_initial_share?(edge)
          recolor_label('?!', true)
        else
          super
        end
      end

      def node_label(node)
        recolor_label(super, ! node.get(:demand))
      end

      def no_initial_share?(edge)
        edge.get(:parent_share).nil? && edge.get(:child_share).nil?
      end
    end # InitialValues
  end # Diagram
end # Refinery
