module EventSequence
  class SequenceRunner
    attr_accessor :sequence

    def initialize(sequence)
      self.sequence = sequence
    end

    def self.perform(q_options:, props:)
      sequence = q_options[:sequence].constantize.new(*props)
      sequence.id = q_options[:id]
      EventSequence::SequenceExecutor.new(sequence).process
    end

    def process(previous = nil)
      record = sequence.db_status
      sequence.id = record.id

      sequence.db_initiated
      sequence.db_queued if sequence.queue.present?
      # sequence.db_waiting if sequence.wait.present?

      (sequence.queue.blank? ? self.class.method(:perform) : job_method).call(
        q_options: q_options, props: sequence.props
      )
    end

    def q_options
      { sequence: sequence.class.name, queue: sequence.queue.to_s, id: sequence.db_queued.id }
    end

    def job_method
      "#{job_class}".constantize.method(perform_method)
    end

    def job_class
      'SequenceJob'
    end

    def job_sync_execute_method
      :perform_later
    end

    def job_async_execute_method
      :perform_later
    end

    def perform_method
      sync? ? job_sync_execute_method : job_async_execute_method
    end

    def sync?
      %w(test development).include? Rails.env
    end
  end
end
