module WampRails
  module Command

    class Publish < Base
      attr_accessor :topic, :args, :kwargs, :options

      def initialize(topic, args, kwargs, options)
        super
        self.topic = topic
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute(session)
        session.publish(self.topic, self.args, self.kwargs, self.options, self.callback)
      end

    end

  end
end
