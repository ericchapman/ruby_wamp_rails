module WampRails
  module Command
    class BaseCommand
      attr_accessor :queue, :client

      # The callback object to place in the queue
      class CallbackArgs
        attr_accessor :result, :error, :details
        def initialize(result, error, details)
          self.result = result
          self.error = error
          self.details = details
        end
      end

      def initialize(queue, client)
        self.queue = queue
        self.client = client
      end

      # Executes the command.  This is called by the library in the EM Thread
      def execute(session)
        # Override when sub classing
      end

      # Used in sub-classes to handle the response
      def callback(result, error, details)
        self.queue&.push(CallbackArgs.new(result, error, details))
      end

    end
  end
end
