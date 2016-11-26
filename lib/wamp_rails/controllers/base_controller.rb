module WampRails
  module Controller
    class BaseController

      def initialize(args, kwargs, details, client)
        @args = args || []
        @kwargs = kwargs || {}
        @details = details || {}
        @client = client
      end

      def handler
        raise WampRails::Error.new('WampRails::Controller::Base is an abstract class. "handler" must be defined')
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

      def client
        @client
      end

    end
  end
end
