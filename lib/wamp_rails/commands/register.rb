module WampRails
  module Command
    class Register < Base
      attr_accessor :procedure, :klass, :options

      def initialize(procedure, klass, options)
        super()
        self.procedure = procedure
        self.klass = klass
        self.options = options

        unless self.klass < WampRails::Controller::Register
          raise Exception.new('klass must be a WampRails::Controller::Register class')
        end
      end

      def execute(session)
        session.register(self.procedure, self.klass.method(:handler), self.options) do |result, error, details|
          self.callback(result, error, details)
        end
      end
    end
  end
end
