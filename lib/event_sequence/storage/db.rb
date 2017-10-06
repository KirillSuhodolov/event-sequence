module EventSequence
  module Storage
    module Db
      extend ActiveSupport::Concern

      STATUS_QUEUED = 'queued'
      STATUS_WORKING = 'working'
      STATUS_COMPLETED = 'completed'
      STATUS_FAILED = 'failed'
      STATUS_KILLED = 'killed'
      STATUS_INITIATED = 'initiated'
      STATUS_WAITING = 'waiting'

      STATUSES = [
        STATUS_QUEUED,
        STATUS_WORKING,
        STATUS_COMPLETED,
        STATUS_FAILED,
        STATUS_KILLED,
        STATUS_INITIATED,
        STATUS_WAITING
      ].freeze

      attr_accessor :id, :parent_id, :child_ids

      # sequence initiated
      #
      def db_initiated(message = "Initiated at #{Time.zone.now}")
        update_db_status({ status: STATUS_INITIATED, message: message })
      end

      # sequence waiting for described sequences have completed status
      def db_waiting(messafge = "Waiting at #{Time.zone.now}")
        update_db_status({ status: STATUS_WAITING, message: message })
      end

      # sequence processing events and child sequences
      def db_working(message = "Started at #{Time.zone.now}")
        update_db_status({ status: STATUS_WORKING, message: message, attempts: db_status.attempts + 1 })
      end

      # with this status sequence exists in a gap between it initiated and called in background
      def db_queued(message = "Queued at #{Time.zone.now}")
        update_db_status({ status: STATUS_QUEUED, message: message })
      end

      # sequence execution error
      def db_failed(e)
        update_db_status({ status: STATUS_FAILED, message: e.to_s })
      end

      # final status - sequence executed succesfully
      def db_completed(message = "Completed at #{Time.zone.now}" )
        update_db_status({ status: STATUS_COMPLETED, message: message })
      end

      def update_db_status(params)
        db_status.update(params) && db_status
      end

      def update_children
        update_db_status({ child_ids: children&.map { |child| child.db_queued.id }  })
      end

      def db_status
        @db_status ||= id ? db_model.find(id) : db_status_new
      end

      def add_children

      end

      def change_status

      end

      def db_model
        '::SequenceRecord'.constantize
      end

      def db_status_new
        db_model.new(
          queue: queue,
          signature: self.class.to_s,
          parent_id: parent&.id,
          props: props,
          child_ids: children&.map(&:id)
        )
      end
    end
  end
end
