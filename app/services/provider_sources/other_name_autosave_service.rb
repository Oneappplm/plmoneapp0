# app/services/provider_source/other_name_autosave_service.rb
module ProviderSources
  class OtherNameAutosaveService
    FIELD_MAP = {
      "date_started" => "start_date",
      "date_stopped" => "end_date",
      "first_name"   => "first_name",
      "last_name"    => "last_name",
      "middle_name"  => "middle_name",
      "name_type"    => "name_type",
      "in_use" => "in_use"
    }.freeze

    def initialize(source:, field_name:, value:, other_name_id:)
      @source = source
      @field_name = field_name
      @value = value
      @other_name_id = other_name_id
    end

    def perform
      index, attribute = extract_index_and_attribute(@field_name)
      return { error: "Invalid field name" } unless attribute

      other_name = find_or_initialize_other_name
      other_name.assign_attributes(attribute => @value)

      if other_name.save(validate: false)
        sync_to_provider_other_name(other_name, attribute, @value)
        { status: "saved", id: other_name.id }
      else
        { error: other_name.errors.full_messages }
      end
    end

    private

    def extract_index_and_attribute(field_name)
      if field_name =~ /\Aother_names\[(\d+)\]\[(\w+)\]\z/
        [Regexp.last_match(1).to_i, Regexp.last_match(2)]
      else
        [nil, nil]
      end
    end

    def find_or_initialize_other_name
      if @other_name_id.present?
        @source.other_names.find_or_initialize_by(id: @other_name_id)
      else
        @source.other_names.build
      end
    end

    def sync_to_provider_other_name(other_name, attribute, value)
      attest = @source.provider_personal_information.provider_attest
      return unless attest
      provider_other_name =
        if @other_name_id.present?
          attest.provider_other_names.find_by(caqh_provider_other_name_id: other_name.id)
        else
          attest.provider_other_names.build(provider_attest_id: attest.id, caqh_provider_other_name_id: other_name.id)
        end

      db_field = FIELD_MAP[attribute]
      return unless db_field.present? && provider_other_name.respond_to?("#{db_field}=")

      provider_other_name.send("#{db_field}=", value)
      provider_other_name.save(validate: false)
    end
  end
end
