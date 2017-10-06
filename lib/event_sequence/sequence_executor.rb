module EventSequence
  class SequenceExecutor
    include EntityCheck
    include Generators

    attr_accessor :sequence

    def initialize(sequence)
      self.sequence = sequence
    end

    # how to add system events? that will be called, but will not affect on result
    # for example: serializer event should serialize data for pass to next sequence,
    # but shouldn't affect on result that current sequence will return
    # [:a, :b, NextSequence]
    # [:a, :b, :system_serialize, NextSequence]
    # it cannot be first at NextSequence, because it will executed at other runtime
    # it looks like branching
    # may I create event, that will detect exit and will not change result any more
    # like [:a, :b, :its_exit, :system_serialize NextSequence]
    # class ItsExit < EventSequence::Event
    #   def perform(params)
    #
    #   end
    #
    #   def affects?
    #     false
    #   end
    # end
    # explicitly describing what each event returns, will not solve issue such events as: serialzier
    # system event for: serialize, create sequence record, put to wait, run wait, and etc,
    # like enchancing sequence queue

    # the task to have flexible mechanism, that can give ability to create event sequences,
    # manage them,
    # easily as in runtime, same in background
    # ability branching, recording and writing to storage history

    # build record from params inside operation
    # should pundit called here or at controller?

    # the main question how pass params and result to next event?
    # how store them: or should they be stored
    # for example sequence record created before it executed, and props will not have result params.
    # variants: via argument method, avialbe in scope,

    # if wait key in sequence, it should be putted to the queue, created database projection,
    # it shouldn't executed at current runtime
    # added event to the end of each watched sequence
    # at that event when it executed should checked that(should? method)
    # it should be system event
    # need store what other sequences it wait
    # should? method should get list ids of waited sequences, fetch it statuses
    # if all statuses completed_status then continue processing

    # how to avoid, adding system event to watced sequences?
    # after sequence should be called every time when watched sequence completed
    # add next field
    # where/how store list of what to wait? - at after_ids field
    # is it really need next_id field?
    # algorithm to check should it be runned:
    # on create instance if sequence contains wit(after)
    # then fill it wait_ids array by what it wait and store at database
    # add to each sequence that waited next_id
    # when sequence processing, check at the end, if contains next_id
    # if contains, find, next sequence by id
    # get wait array from next sequence and check is all completed, if completed - run
    # run mean run in runtime ? or put to queue?
    # think only at that time put to queue
    # before it next sequence should be just initated

    # isn't wait and child same, as child contins wait records, because it child


    # at this method all sequences have stored projections with id
    def process
      # return if sequence.should_wait?
      #
      sequence.db_working

      input = sequence.input
      events = sequence.events
      fail_events = sequence.fail_events

      last_event_result = input.first
      instantiated_sequences = []

      events.map do |event|
        passed_data = [*input, last_event_result]
        event_or_sequence_instance = make_event_instance(event).new(*passed_data)

        begin
          if event_or_sequence_instance.is_event
            result = event_or_sequence_instance.process(last_event_result)
            last_event_result = result
          end

          if event_or_sequence_instance.is_sequence
            # fill parent
            event_or_sequence_instance.parent = sequence
            result = event_or_sequence_instance.process(last_event_result)

            # if event_or_sequence_instance.wait.present?
            #
            # end

            instantiated_sequences << event_or_sequence_instance
          end
        rescue => e
          sequence.db_failed(e)

          fail_events.each do |fail_event|
            fail_event_instance = make_event_instance(fail_event).new(*passed_data)
            fail_event_instance.process(e)
          end

          raise e
        end
      end

      # fill children
      sequence.children = instantiated_sequences

      # fill wait
      # instantiated_sequences.map do |instantiated_sequence|
      #   instantiated_sequence.db_status.wait_ids = instantiated_sequences
      #     .select { |is| instantiated_sequence.wait.include? is.class  }
      #     .map { |is| is.id }
      #
      #   instantiated_sequence.db_status.save
      # end

      # fill next
      # instantiated_sequences.map do |instantiated_sequence|
      #   instantiated_sequence.db_status.next_ids = instantiated_sequences
      #     .select { |is| is.db_status.wait.include? instantiated_sequences.class }
      #
      #   instantiated_sequence.db_status.save
      # end

      # run wait for sync sequences
      # instantiated_sequences
      #   .select { |instantiated_sequence| instantiated_sequence.wait.present? }
      #   .map { |instantiated_sequence| instantiated_sequence.process }

      # generate sequence from id to run next?
      # sequence.db_status.next_ids.

      sequence.update_children
      sequence.db_completed

      last_event_result
    end
  end
end
