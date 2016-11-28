module WampRails
  module Queue

    class Base

      # Pushes and object into the queue
      def push(object)
      end

      # Pops an object from the queue
      def pop
      end

      # Returns true if empty
      def empty?
      end

    end

    class Thread < Base

      def initialize
        @queue = ::Queue.new
      end

      def push(object)
        @queue.push(object)
      end

      def pop
        @queue.pop
      end

      def empty?
        @queue.empty?
      end

    end

  end
end