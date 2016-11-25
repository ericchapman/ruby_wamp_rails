require 'wamp_rails'

module WampRails
  module Controller
    class Subscribe < Base

      def received
        self.published
      end

      def published
        # Override when sub-classing
      end
    end
  end
end