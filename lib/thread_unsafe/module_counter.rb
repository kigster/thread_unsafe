# frozen_string_literal: true

module ThreadUnsafe
  # @description A simple counter that can be incremented by multiple threads.
  # @note This class is not thread-safe, unless increment(safely: true) is used.
  module ModuleCounter
    class << self
      attr_reader :count

      def reset
        with_mutex { @count = 0 }
      end

      # This increment method is deliberately not using any synchronization,
      # and uses a read-modify-write approach that can be interrupted by other threads.
      def increment(safely: false)
        if safely
          with_mutex { unsafe_increment }
        else
          unsafe_increment
        end
      end

      private

      def with_mutex(&)
        mutex.synchronize(&)
      end

      def unsafe_increment
        current = count || 0
        # Force a tiny pause to encourage context switches
        # and make race conditions more likely to appear.
        sleep(0.000001) if rand(100) < 50
        @count = current + 1
      end

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
