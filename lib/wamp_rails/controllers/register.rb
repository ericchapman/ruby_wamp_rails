module WampRails
  module Controller
    class Register < Base

      def received
        self.called
      end

      def called
        # Override when sub-classing
      end

    end
  end
end
