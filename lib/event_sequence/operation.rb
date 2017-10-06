module EventSequence
  class Operation
    attr_accessor :input

    def initialize(*args)
      self.input = args
    end

    def sequence
    end

    def process
      EventSequence::SequenceRunner.new(sequence.new(*input)).process
    end
  end
end
