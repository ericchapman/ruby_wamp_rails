module WampRails
  module Command
    class Subscribe < Base
      attr_accessor :topic, :klass, :options

      def initialize(topic, klass, options)
        super()
        self.topic = topic
        self.klass = klass
        self.options = options

        unless self.klass < WampRails::Controller::Subscribe
          raise Exception.new('klass must be a WampRails::Controller::Subscribe class')
        end
      end

      def execute(session)
        session.subscribe(self.topic, self.klass.method(:handler), self.options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end
  end
end
