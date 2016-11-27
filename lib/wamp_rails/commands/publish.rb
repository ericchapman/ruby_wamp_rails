module WampRails
  module Command

    class Publish < BaseCommand
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

  end
end
