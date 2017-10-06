module EventSequence
  class Sequence
    include EventSequence::Storage::Db
    include EventSequence::Waiter
    include EventSequence::Validation

    attr_accessor :input, :sequence_options, :parent, :children

    class << self
      attr_accessor :sequence_options, :sequence_options_mixin

      def sequence(options = { queue: nil, events: [], fail: [], wait: [], serializer: nil })
        self.sequence_options = options
      end

      def sequence_mixin(options = { queue: nil, events: [], fail: [], wait: [], serializer: nil })
        self.sequence_options_mixin = options
      end
    end

    def initialize(*args)
      self.sequence_options = {}.merge(**(self.class.sequence_options_mixin || {}), **(self.class.sequence_options || {}))
      self.input = args
    end

    def serializer_class_name
      'SequenceSerializer'
    end

    def serializer
      @serializer ||= self.sequence_options[:serializer] || lookup_serializer
    end

    def fail_events
      @fail_events ||= sequence_options[:fail] || []
    end

    def wait
      @wait ||= sequence_options[:wait] || []
    end

    def queue
      @queue ||= self.sequence_options[:queue]
    end

    def events
      @events ||= self.sequence_options[:events].blank? ? lookup_events : self.sequence_options[:events]
    end

    # lookup serializer in upper scope
    def lookup_serializer
      "#{self.class.name.split('::')[0...-1].join('::')}::#{serializer_class_name}".safe_constantize
    end

    def lookup_events
      self.public_methods(false) - Object.new.methods
    end

    def should?
      true
    end

    def is_sequence
      true
    end

    def is_event
      false
    end

    def props
      serializer ? [serializer.new(*input).process] : input
    end

    def process(previous = nil)
      should? && EventSequence::SequenceRunner.new(self).process(previous)
    end
  end
end
