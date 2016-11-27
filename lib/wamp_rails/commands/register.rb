module WampRails
  module Command
    class Register < BaseHandler
      attr_accessor :procedure, :options

      def initialize(queue, procedure, klass, options, client)
        super(queue, client, klass)
        self.procedure = procedure
        self.options = options

        unless self.klass < WampRails::Controller::Procedure
          raise WampRails::Error.new('klass must be a WampRails::Controller::Procedure class')
        end
      end

      def execute(session)
        session.register(procedure, handler, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end
  end
end
