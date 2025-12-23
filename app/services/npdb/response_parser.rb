# app/services/npdb/response_parser.rb
module Npdb
  class ResponseParser
    def initialize(xml)
      @doc = Nokogiri::XML(xml)
    end

    def parse
      {
        status: status,
        submit_date: Time.current,
        response_date: Time.current,
        comments: summary
      }
    end

    def status
      @doc.at_xpath('//Status')&.text || 'NO_HIT'
    end

    def summary
      @doc.at_xpath('//Summary')&.text || 'No reports found'
    end
  end
end
