module WampRails
  module Command
    class Base
      attr_accessor :queue

      # The callback object to place in the queue
      class CallbackArgs
        attr_accessor :result, :error, :details
        def initialize(result, error, details)
          self.result = result
          self.error = error
          self.details = details
        end
      end

      def initialize
        self.queue = Queue.new
      end

      # Executes the command.  This is called by the library in the EM Thread
      # @param session[WampClient::Session] - The wamp session
      def execute(session)
        # Override when sub classing
      end

      # Used in sub-classes to handle the response
      def callback(result, error, details)
        self.queue.push(CallbackArgs.new(result, error, details))
      end

    end
  end
end
