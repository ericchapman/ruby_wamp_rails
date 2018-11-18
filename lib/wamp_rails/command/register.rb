require_relative "handler"

module WampRails
  module Command
    class Register < Handler
      attr_accessor :procedure, :options

      def initialize(procedure, klass, options, client)
        super(client, klass)
        self.procedure = procedure
        self.options = options

        unless self.klass < WampRails::Controller::Procedure
          raise WampRails::Error.new('klass must be a WampRails::Controller::Procedure class')
        end
      end

      def execute
        session.register(procedure, handler, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end
  end
end
