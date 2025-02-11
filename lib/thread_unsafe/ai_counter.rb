# frozen_string_literal: true

module ThreadUnsafe
  module AICounter
    class << self
      attr_reader :count

      def reset
        with_mutex { @count = 0 }
      end

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
        sleep(0.000001) if rand(100) < 50
        @count = current + 1
      end

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
