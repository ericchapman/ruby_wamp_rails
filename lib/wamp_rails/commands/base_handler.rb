module WampRails
  module Command
    class BaseHandler < BaseCommand
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
  end
end