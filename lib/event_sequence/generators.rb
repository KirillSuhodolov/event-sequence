module EventSequence
  module Generators
    def generate_sequence_class(options)
      Class.new EventSequence::Sequence do
        sequence options
      end
    end

    def generate_event_class_from_lamda(options)
      Class.new EventSequence::Event do
        define_method(:perform, options)
      end
    end

    def generate_event_class_from_method(options)
      perform_method = sequence.method(options)

      Class.new EventSequence::Event do
        define_method(:perform, ->(result) {perform_method.call(result)})
      end
    end

    def make_event_instance(event)
      if is_hash(event)
        generate_sequence_class(event)
      elsif is_symbol(event)
        generate_event_class_from_method(event)
      elsif is_lambda(event)
        generate_event_class_from_lamda(event)
      else
        event
      end
    end
  end
end
