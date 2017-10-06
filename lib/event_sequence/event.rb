module EventSequence
  class Event
    attr_accessor :input

    def initialize(*args)
      self.input = args
    end

    def is_sequence
      false
    end

    def is_event
      true
    end

    def should?
      true
    end

    # method that should store logic
    def perform
    end

    def process(previous = nil)
      should? && EventSequence::EventRunner.new(self).process(previous)
    end
  end
end
