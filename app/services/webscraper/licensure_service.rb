module Webscraper
  class LicensureService
    SCRAPERS = YAML.load_file(
      Rails.root.join("config", "licensure_scrapers.yml")
    ).with_indifferent_access

    def initialize(license_number, state_id)
      @license_number = license_number
      @state = State.find(state_id)
      # @first_name = first_name
      # @last_name = last_name
    end

    def call
      config = SCRAPERS[@state.alpha_code]

      raise "No scraper registered for #{@state.alpha_code}" if config.blank?

      scraper_class = config[:class].constantize

      scraper = scraper_class.new(
        @license_number,
        @state,
        config[:url],
        # first_name: @first_name,
        # last_name: @last_name
      )

      scraper.crawl!
    end
  end
end
