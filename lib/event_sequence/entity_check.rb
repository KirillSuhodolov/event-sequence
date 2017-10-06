module EventSequence
  module EntityCheck
    def is_event(obj)
      obj.is_a? EventSequence::Event
    end

    def is_sequence(obj)
      obj.is_a? EventSequence::Sequence
    end

    def is_hash(obj)
      obj.is_a? Hash
    end

    def is_lambda(obj)
      obj.is_a? Proc
    end

    def is_symbol(obj)
      obj.is_a? Symbol
    end
  end
end
