# frozen_string_literal: true

require_relative "thread_unsafe/version"

module ThreadUnsafe
  class Error < StandardError; end
  # Your code goes here...
end

require_relative "thread_unsafe/module_counter"
require_relative "thread_unsafe/class_counter"
