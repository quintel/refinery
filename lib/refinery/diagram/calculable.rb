module Refinery
  module Diagram
    # A diagram which shows the calculable nodes normally, fading the
    # incalculable elements into the background.
    class Calculable < Incalculable
      private

      def recolor_label(label, transparent)
        super(label, ! transparent)
      end

      def recolor_options(label, transparent)
        super(label, ! transparent)
      end
    end # Calculable
  end # Diagram
end # Refinery
