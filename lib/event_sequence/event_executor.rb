module EventSequence
  class EventExecutor
    attr_accessor :event

    def initialize(event)
      self.event = event
    end

    def process(previous = nil)
      event.perform(previous)
    end
  end
end
