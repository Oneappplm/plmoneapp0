module Webscraper
  module States
    class BaseScraper
      def initialize(license_number, state, url)
        @license_number = license_number
        @state = state
        @url = url
      end

      def crawl!
        raise NotImplementedError, "Subclasses must implement crawl!"
      end
    end
  end
end
