module EventSequence
  class Sequence::Low < EventSequence::Sequence
    def queue
      :low
    end
  end
end
