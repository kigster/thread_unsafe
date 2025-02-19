# frozen_string_literal: true

require_relative "thread_unsafe/version"

module ThreadUnsafe
  class Error < StandardError; end
end

require_relative "thread_unsafe/incrementer"
require_relative "thread_unsafe/cow_counter"
require_relative "thread_unsafe/class_counter"
