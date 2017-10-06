module EventSequence
  module Waiter
    # is that should be wait finished
    def should_wait?
      db_status.status == STATUS_WAITING && get_list(:wait_ids).all? { |record| record.status === STATUS_COMPLETED }
    end

    def get_list(key)
      db_status[key].map { |id| db_status.db_model.find(id) }
    end
  end
end
