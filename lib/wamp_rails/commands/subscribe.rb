module WampRails
  module Command
    class Subscribe < BaseHandler
      attr_accessor :topic, :klass, :options

      def initialize(topic, klass, options, client)
        super(client, klass)
        self.topic = topic
        self.options = options

        unless self.klass < WampRails::Controller::Subscription
          raise WampRails::Error.new('klass must be a WampRails::Controller::Subscription class')
        end
      end

      def execute
        session.subscribe(topic, handler, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end
  end
end
