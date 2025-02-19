# frozen_string_literal: true

module ThreadUnsafe
  # @description A class-level variable @@count can be incremented by multiple threads.
  # @note This class is not thread-safe, unless increment(safely: true) is used.
  # noinspection RubyClassVariableUsageInspection
  class ClassCounter
    include Incrementer
    self.incrementable_attribute = :@@count

    def initialize
      @@count = 0
    end

    def count
      @@count
    end

    def count=(value)
      @@count = value
    end
  end
end
