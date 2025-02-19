# frozen_string_literal: true

module ThreadUnsafe
  # @description A simple counter that can be incremented by multiple threads.
  # @note This class is not thread-safe, unless increment(safely: true) is used.
  module CowCounter
    class << self
      def included(klass)
        klass.instance_eval do
          class << self
            attr_accessor :cows
          end

          include(Incrementer)

          incrementable :@cows
        end
        klass.cows = 0
      end
    end
  end
end
