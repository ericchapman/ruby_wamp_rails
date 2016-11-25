module WampRails
  module Controller
    class Base
      attr_accessor :args, :kwargs, :details, :session

      def self.handler(args, kwargs, details)
        object = self.new(args, kwargs, details)
        object.received
      end

      def initialize(args, kwargs, details)
        @args = args || []
        @kwargs = kwargs || {}
        @details = details || {}
        @session = details[:session]
      end

      def received
        raise Exception.new('WampRails::Controller::Base is an abstract class')
      end

      def args
        @args
      end

      def kwargs
        @kwargs
      end

      def details
        @details
      end

      def session
        @session
      end

    end
  end
end
