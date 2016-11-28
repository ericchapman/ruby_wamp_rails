module WampRails
  module Command

    class Base
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

    class BaseHandler < Base
      attr_accessor :klass

      def handler
        lambda { |args, kwargs, details|
          object = klass.new(args, kwargs, details, client)
          object.handler
        }
      end

      def initialize(queue, client, klass)
        super(queue, client)
        self.klass = klass
      end

    end

    class Call < Base
      attr_accessor :procedure, :args, :kwargs, :options

      def initialize(queue, procedure, args, kwargs, options, client)
        super(queue, client)
        self.procedure = procedure
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute(session)
        session.call(procedure, args, kwargs, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end

    end

    class Publish < Base
      attr_accessor :topic, :args, :kwargs, :options

      def initialize(queue, topic, args, kwargs, options, client)
        super(queue, client)
        self.topic = topic
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute(session)
        session.publish(topic, args, kwargs, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end

    end

    class Register < BaseHandler
      attr_accessor :procedure, :options

      def initialize(queue, procedure, klass, options, client)
        super(queue, client, klass)
        self.procedure = procedure
        self.options = options

        unless self.klass < WampRails::Controller::Procedure
          raise WampRails::Error.new('klass must be a WampRails::Controller::Procedure class')
        end
      end

      def execute(session)
        session.register(procedure, handler, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end

    class Subscribe < BaseHandler
      attr_accessor :topic, :klass, :options

      def initialize(queue, topic, klass, options, client)
        super(queue, client, klass)
        self.topic = topic
        self.options = options

        unless self.klass < WampRails::Controller::Subscription
          raise WampRails::Error.new('klass must be a WampRails::Controller::Subscription class')
        end
      end

      def execute(session)
        session.subscribe(topic, handler, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end

  end
end