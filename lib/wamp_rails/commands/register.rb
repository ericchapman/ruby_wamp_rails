module WampRails
  module Command
    class Register < Base
      attr_accessor :procedure, :klass, :options

      def initialize(procedure, klass, options)
        super
        self.procedure = procedure
        self.klass = klass
        self.options = options

        unless self.klass.is_a? WampRails::Controller::Register
          raise Exception.new('klass must be a WampRails::Controller::Register class')
        end
      end

      def execute(session)
        session.register(self.procedure, self.klass.singleton_method(:handler), self.options, self.callback)
      end
    end
  end
end
