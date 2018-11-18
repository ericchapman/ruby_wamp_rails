require_relative 'base'

module WampRails
  module Command
    class Handler < Base
      attr_accessor :klass

      def handler
        lambda { |args, kwargs, details|
          object = klass.new(args, kwargs, details, client)
          object.handler
        }
      end

      def initialize(client, klass)
        super(client)
        self.klass = klass
      end

    end
  end
end