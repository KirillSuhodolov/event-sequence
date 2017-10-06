module EventSequence
  class Sequence::Sync < EventSequence::Sequence
    def queue
      nil
    end
  end
end
