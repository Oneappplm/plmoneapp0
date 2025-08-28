module ProviderSources
  class DisclosureAutosaveService
    def initialize(source:, field_name:, value:)
      @source = source
      @field_name = field_name
      @value = value
      @slug, @type = parse_field_name(field_name)
    end

    def perform
      return { error: "Missing provider attest" } unless provider_attest
      question = DisclosureQuestion.find_by(slug: @slug)
      return { error: "Invalid question slug: #{@slug}" } unless question

      disclosure = ProviderDisclosure.find_or_initialize_by(
        provider_attest_id: provider_attest.id,
        disclosure_question_disclosure_summary: question.question
      )

      # Always set CAQH ID if available from the question
      disclosure.caqh_provider_disclosure_id = question.id

      case @type
      when :answer
        disclosure.disclosure_answer_flag = @value == "yes"
      when :explanation
        disclosure.disclosure_explanation = @value
      end

      disclosure.disclosure_date ||= Time.current

      if disclosure.save(validate: false)
        { status: "saved", id: disclosure.id }
      else
        { error: disclosure.errors.full_messages }
      end
    end

    private

    def provider_attest
      @provider_attest ||= @source.provider_personal_information&.provider_attest
    end

    def parse_field_name(field_name)
      if field_name.ends_with?("_explanation")
        [field_name.gsub(/_explanation\z/, ""), :explanation]
      else
        [field_name, :answer]
      end
    end
  end
end
