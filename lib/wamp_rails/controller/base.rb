module WampRails
  module Controller
    class Base
      attr_reader :args, :kwargs, :details, :client

      def initialize(args, kwargs, details, client)
        @args = args || []
        @kwargs = kwargs || {}
        @details = details || {}
        @client = client
      end

      def handler
        raise WampRails::Error.new('WampRails::Controller::Base is an abstract class. "handler" must be defined')
      end

    end
  end
end
