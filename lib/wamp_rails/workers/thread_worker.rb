module WampRails
  module Worker
    class ThreadWorker < BaseWorker
      attr_accessor :thread

      def initialize(options)
        super(options)
        @cmd_queue = Queue.new
      end

      def cmd_queue
        @cmd_queue
      end

      def open
        self.thread = Thread.new do
          super()
        end
      end
    end
  end
end