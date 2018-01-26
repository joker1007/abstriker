# Abstriker
[![Build Status](https://travis-ci.org/joker1007/abstriker.svg?branch=master)](https://travis-ci.org/joker1007/abstriker)

This gem adds `abstract` syntax. that is similar to Java's one.
`abstract` modified method requires subclass implementation.

If subclass does not implement `abstract` method, raise `Abstriker::NotImplementedError`.
`Abstriker::NotImplementedError` is currently subclass of `::NotImplementedError`.

This gem is pseudo static code analyzer by `TracePoint` and `Ripper`.
it detect abstract violation when class(module) is defined, not runtime.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abstriker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install abstriker

## Usage

```ruby
class A1
  extend Abstriker

  abstract def foo
  end
end

class A3 < A1
  def foo
  end
end # => OK

class A2 < A1
end # => raise

Class.new(A1) do
end # => raise
```

### for Production
If you want to disable Abstriker, write `Abstriker.disable = true` at first line.
If Abstriker is disabled, TracePoint never runs, and so there is no overhead of VM instruction.

### Examples

#### include module

```ruby
module B1
  extend Abstriker

  abstract def foo
  end
end

class B2
  include B1
end # => raise

Module.new do
  include B1
end # => raise
```

#### include module outer class definition
```ruby
module A1
  extend Abstriker

  abstract def foo
  end
end

class A2;
end

A2.include(A1) # => raise
```

#### extend module

```ruby
module C1
  extend Abstriker

  abstract def foo
  end
end

class C3
  extend C1

  def self.foo
  end
end # => OK

class C2
  extend C1
end # raise
```

#### singleton class

```ruby
class D1
  extend Abstriker

  class << self
    abstract def foo
    end
  end
end

class D3 < D1
  def self.foo
  end
end # => OK

class D2 < D1
end # => raise

Class.new(D1) do
end # => raise

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joker1007/abstriker.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
