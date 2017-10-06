# EventSequence

This gem run understandable logic

## Important Notice

WIP, be careful with using it. Contributors are welcome!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'event_sequence'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install event_sequence

## Usage

Call operation at your controllers

```ruby
class EntityController < ApplicationController
  def create
    op = EntityOperation::Create.new(params, current_user)

    op.process

    if op.success?
      render json: op.result, status: :created
    else
      render json: { errors: op.result.errors }, status: :unprocessable_entity
    end
  end
end
```

Move you model callbacks to operation

```ruby
module EntityOperation
  class Create < EventSequence::Sequence
    class SequenceSerializer < EventSequence::Serializer
      RECORD_FIELDS = %i(id name order_id).freeze
    end

    def build_record(params)
      params
    end

    class ChecPermissionsEvent < EventSequence::Event
      def process(record)
      end

      def should?
        true
      end
    end

    def create_order(record)
      record.save && record
    end

    def refetch_order(record)
      record.reload
    end

    def on_fail(e)
      puts "FailEvent #{e}"
    end

    class BroadcastSequence < EventSequence::Sequence::Low
      def broadcast(props)
        BroadcastService.new(props).process
      end
    end

    class NotifySequence < EventSequence::Sequence::Low
      def notify(props)
        NotificationService.new(props).process
      end
    end

    class FeedSequece < EventSequence::Sequence::Low
      def populate_feed(props)
        ActivityFeedService.new(props).create
      end
    end

    class AfterAllSequence < EventSequence::Sequence::Low
      def call_me_after_all(props)
        puts "#{call_me_after_all} props"
      end

      def on_fail_after_all(e)
        puts "After all fail #{e}"
      end

      sequence({
        events: [:call_me_after_all],
        fail: [:on_fail_after_all],
        wait: [BroadcastSequence, FeedSequece, NotifySequence]
      })
    end

    sequence({
      events: [
        :build_record,
        ChecPermissionsEvent,
        :create_order,
        :refetch_order,
        BroadcastSequence,
        FeedSequece,
        NotifySequence,
        AfterAllSequence,
      ],
      serializer: SequenceSerializer,
      fail: [:on_fail]
    })
  end
end
```

## Difference with [operationable](https://github.com/KirillSuhodolov/operationable)
Unlike [operationable](https://github.com/KirillSuhodolov/operationable) gem, this gem based only on two mandatory classes: Sequence and Event
No separating by main operation and callbacks any more. Cause operation is sequence of events and callbacks are sequences for events too.
Advantage of this is ability to create sequences and events on flight

## Classes
Main: Sequence and Event.
Extra classes: Serializer, Waiter, Persister, Logger

### Event
The atomic pice of code. Can defined as Classes(when you need specification), methods and lambdas.

### Sequence
Collection on sequence, each next event gets result of previous event execution. Sequences can be executed in the same runtime, or in different.
At different runtime, passed params should be given for primitive types.
Can defined as Classes with many methods, or just one, if many sequence method call required.

### Specification
Event and Sequence both have method .should?. By default it true. Very useful when you need split execution with check conditions.

### Runner
Internal class to run
Operations work via ActiveJob, so you can use any adapter that you want.

## Sequence definition
sequence class method class with required params. Only events mandatory value.

### events
Put your logic there, events will execute one by one. Sequence and events same for execution, different only that sequence don't modify passed values.

### fail
The branch that executes if something fail in events

### serializer
Class that used to modify passed to sequence params.

### wait
array of siblings, after which sequence will be started  

### queue
Background job queue. Run important and urgent Sequences with priority. Bye default it's nil - mean that sequence is sync.

## System events
System events - events that live in sequence but it's not business logic events.
To such events can be attributed: Serializer, Waiter, Persister, Logger

### Serializer
Serializer required for sequences that run in background.
Serializer used to define what values should be passed to job(redis do not accept AR instances or other complex structures).
Also you don't need all record fields should passed to callbacks.

### Waiter
Need to run special sequence only after list of others executed in others runtimes

### Logger
Logging execution

### Persister
Store in database, execution process with current status, time in work, estimated time, who done and etc

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Contributions are welcome!

Contributors:
[kirillsuhodolov](https://github.com/KirillSuhodolov)


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
