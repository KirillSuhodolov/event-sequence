module EventSequence
  class EventRunner
    attr_accessor :event

    def initialize(event)
      self.event = event
    end

    def process(previous = nil)
      EventSequence::EventExecutor.new(event).process(previous)
    end
  end
end
