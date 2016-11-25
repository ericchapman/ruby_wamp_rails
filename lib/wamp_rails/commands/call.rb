module WampRails
  module Command

    class Call < Base
      attr_accessor :procedure, :args, :kwargs, :options

      def initialize(procedure, args, kwargs, options)
        super()
        self.procedure = procedure
        self.args = args
        self.kwargs = kwargs
        self.options = options
      end

      def execute(session)
        session.call(self.procedure, self.args, self.kwargs, self.options) do |result, error, details|
          self.callback(result, error, details)
        end
      end

    end

  end
end