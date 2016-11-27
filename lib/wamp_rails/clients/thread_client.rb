module WampRails
  module Client
    class ThreadClient < BaseClient

      def initialize(worker, options)
        super(options)
        @worker = worker
      end

      def cmd_queue
        @worker.cmd_queue
      end

      def response_queue
        Queue.new
      end

    end
  end
end