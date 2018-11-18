require_relative 'base'

module WampRails
  module Command
    class Publish < Base
      attr_accessor :topic, :args, :kwargs, :options

      def initialize(topic, args, kwargs, options, client)
        super(client)
        self.topic = topic
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute
        session.publish(topic, args, kwargs, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end

    end

  end
end
