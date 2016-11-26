module WampRails
  module Command

    class Call < BaseCommand
      attr_accessor :procedure, :args, :kwargs, :options

      def initialize(procedure, args, kwargs, options, client)
        super(client)
        self.procedure = procedure
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute
        session.call(procedure, args, kwargs, options) do |result, error, details|
          self.callback(result, error, details)
        end
      end

    end

  end
end