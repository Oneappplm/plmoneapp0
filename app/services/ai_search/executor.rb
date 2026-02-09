# app/services/ai_search/executor.rb

module AiSearch
  class Executor
    def initialize(query)
      @query = query
    end

    def call
      intent = IntentParser.new(@query).call
      Rails.logger.info("AI Intent : #{intent.inspect}")
      QueryRouter.new(intent).call
    end
  end
end
