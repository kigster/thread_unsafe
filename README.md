[![RSpec](https://github.com/kigster/thread_unsafe/actions/workflows/rspec.yml/badge.svg)](https://github.com/kigster/thread_unsafe/actions/workflows/rspec.yml)
[![Rubocop](https://github.com/kigster/thread_unsafe/actions/workflows/rubocop.yml/badge.svg)](https://github.com/kigster/thread_unsafe/actions/workflows/rubocop.yml)

# ThreadUnsafe

This gem contains various experimens with thread safe and thread-unsafe code with rspecs. Consider it a playground to verify thread safety and observe race conditions.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add thread_unsafe
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install thread_unsafe
```

## Usage

The gem provides a `ThreadUnsafe` module that can be included in a class to make it thread-unsafe. 

```ruby
module CowCounter
  class << self
    def included(klass)
      klass.instance_eval do
        class << self
          attr_accessor :cows
        end

        include ThreadUnsafe::Incrementer
        incrementable :@cows
      end
      
      klass.cows = 0
    end
  end
end

CowCounter.increment(by: 20, with_mutex: true)
CowCounter.cows # => 20
```

Or, using a class:

```ruby
class ClassCounter
  include ThreadUnsafe::Incrementer
  
  self.incrementable_attribute = :@@count
  
  # The following does not work for some reason, but the above assignment does
  # incrementor :@@count 

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

ClassCounter.increment(by: 1, with_mutex: true)
ClassCounter.new.count # => 1
ClassCounter.increment(by: 1, with_mutex: true)
ClassCounter.new.count # => 2
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/thread_unsafe.
