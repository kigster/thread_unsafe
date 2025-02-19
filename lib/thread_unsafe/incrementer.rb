# frozen_string_literal: true

# rubocop: disable Metrics/MethodLength

module ThreadUnsafe
  # @description A simple counter that can be incremented by multiple threads.
  module Incrementer
    class << self
      # @param [Object] klass the class that includes this module
      # @return [Objects] the class that includes this module
      def included(klass)
        # noinspection RubySuperCallWithoutSuperclassInspection
        super

        klass.include(ThreadUnsafe::Incrementer::InstanceMethods)
        klass.extend(ThreadUnsafe::Incrementer::ClassMethods)
      end
    end

    # @description Shared methods to increment a counter
    module ClassMethods
      attr_accessor :incrementable_attribute

      def incrementable(attribute)
        self.incrementable_attribute = attribute

        get_method = attribute_method(attribute)[:get]
        symbol     = attribute_symbol(attribute)

        define_method(:__count) do
          send(get_method, symbol)
        end

        set_method = attribute_method(attribute)[:set]

        define_method(:__count=) do |value|
          send(set_method, symbol, value)
        end
      end

      def attribute_symbol(attribute)
        if attribute.to_s.start_with?("@")
          attribute.to_sym
        else
          attribute.to_s.prepend("@").to_sym
        end
      end

      def attribute_method(attribute)
        if attribute.to_s.start_with?("@@")
          { get: :class_variable_get, set: :class_variable_set }
        else
          { get: :instance_variable_get, set: :instance_variable_set }
        end
      end
    end

    # @description Shared methods to increment a counter
    module InstanceMethods
      attr_accessor :__count, :add_delay

      # @description Increments the counter by 1 and returns the new value.
      # @param with_mutex [Boolean] whether to use a mutex for synchronization
      # @param [Integer] by the amount to increment the counter by
      # @return [Object]
      def increment(with_mutex: false, by: 1)
        if with_mutex
          with_mutex { unsafe_increment(by) }
        else
          unsafe_increment(by)
        end

        method = if self.class.incrementable_attribute
                   self.class.attribute_method(self.class.incrementable_attribute)[:set]
                 else
                   attribute_method(incrementable_attribute)[:set]
                 end

        if method =~ /class/
          self.class.send(
            method,
            self.class.incrementable_attribute,
            __count
          )
        else
          send(
            method,
            self.class.incrementable_attribute,
            __count
          )
        end
      end
    end

    private

    def unsafe_increment(by)
      current = __count || 0
      # Force a tiny pause to encourage context switches
      # and make race conditions more likely to appear.
      sleep(0.000001) if rand(100) < 50 && add_delay
      self.__count = current + by
    end

    def with_mutex(&)
      mutex.synchronize(&)
    end

    def mutex
      @mutex ||= Mutex.new
    end
  end
end

# rubocop: enable Metrics/MethodLength
