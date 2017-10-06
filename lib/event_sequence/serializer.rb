module EventSequence
  class Serializer
    attr_reader :record, :user, :params, :result

    RECORD_FIELDS = [].freeze
    USER_FIELDS = %i(id role email name).freeze

    def initialize(record, user, params, result = nil)
      @record = record
      @user = user
      @params = params
      @result = result
    end

    def serialize
      stringify_arguments(extract_props(record, user))
    end

    def process
      serialize
    end

    private

    def activity
      operation_class_name.split('::').last.underscore
    end

    def action_name
      operation_class_name.split('::')[-2..-1].join(' ').titleize
    end

    def operation_class_name
      self.class.name.split('::')[0...-1].join('::')
    end

    def extract_props(record, user)
      {
        **extract_from_record(record),
        **extract_from_user(user),
        params: params,
        activity: activity,
        action_name: action_name
      }
    end

    def extract_from_record(record)
      extracted_props = record_fields.each_with_object({}) do |field, result|
        result[field] = record.try(field)
        result
      end

      extracted_props[:name] = record.class.name

      extracted_props
    end

    def extract_from_user(user)
      user_fields.each_with_object({}) do |field, result|
        result["changed_by_#{field}".to_sym] = user.try(field)
        result
      end
    end

    def record_fields
      self.class.const_get('RECORD_FIELDS')
    end

    def user_fields
      self.class.const_get('USER_FIELDS')
    end

    def stringify_arguments(params)
      params.compact!

      params.transform_values! do |value|
        if value.is_a? Array
          value.map { |i| acceptable_argument?(i) ? i : i.to_s }
        elsif value.is_a? Hash
          stringify_arguments(value)
        else
          acceptable_argument?(value) ? value : value.to_s
        end
      end

      params
    end

    def acceptable_argument?(arg)
      [Numeric, String, NilClass].any? { |t| arg.is_a? t }
    end
  end
end
