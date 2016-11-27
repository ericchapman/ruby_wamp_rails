module WampRails
  module Client
    class BaseClient
      attr_accessor :verbose, :name

      # Constructor for creating a client.  Options are
      # @param options [Hash] The different options to pass to the connection
      # @option options [String] :name - The name of the WAMP Client
      # @option options [Boolean] :verbose - True if you want debug messages printed
      def initialize(options=nil)
        options ||= {}
        self.name = options[:name] || 'default'
        self.verbose = options[:verbose]
      end

      #region WAMP Methods

      # Performs a WAMP call
      # @note This method is blocking if the callback is not nil
      def call(procedure, args=nil, kwargs=nil, options={}, &callback)
        command = WampRails::Command::Call.new(response_queue, procedure, args, kwargs, options, self)
        self._queue_command(command, callback)
      end

      # Performs a WAMP publish
      # @note This method is blocking if the callback is not nil
      def publish(topic, args=nil, kwargs=nil, options={}, &callback)
        command = WampRails::Command::Publish.new(response_queue, topic, args, kwargs, options, self)
        self._queue_command(command, callback)
      end

      # Performs a WAMP register
      # @note This method is blocking if the callback is not nil
      def register(procedure, klass, options={}, &callback)
        command = WampRails::Command::Register.new(response_queue, procedure, klass, options, self)
        self._queue_command(command, callback)
      end

      # Performs a WAMP subscribe
      # @note This method is blocking if the callback is not nil
      def subscribe(topic, klass, options={}, &callback)
        command = WampRails::Command::Subscribe.new(response_queue, topic, klass, options, self)
        self._queue_command(command, callback)
      end

      #endregion

      #region Private Methods

      def _queue_command(command, callback=nil)
        self.cmd_queue.push(command)
        callback_args = command.queue.pop

        if callback
          callback.call(callback_args.result, callback_args.error, callback_args.details)
        end
      end

      #endregion

      #region Override Methods

      def cmd_queue
        # Override me to return the command queue
      end

      def response_queue
        # Override me to return a new response queue
      end

      #endregion
    end
  end
end
