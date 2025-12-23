# app/services/npdb/query_service.rb
require 'savon'
require 'base64'

module Npdb
  class QueryService
    def initialize(provider, npdb)
      @provider = provider
      @npdb     = npdb
    end

    def call
      xml = XmlBuilder.new(@provider, @npdb).build

      client = Savon.client(
        wsdl: Rails.application.credentials.dig(:npdb, :wsdl),
        ssl_verify_mode: :none,  # NPDB sandbox often has SSL quirks
        log: true,
        pretty_print_xml: true,
        open_timeout: 30,
        read_timeout: 60
      )

      response = client.call(
        :submit_query,
        message: { xmlRequest: Base64.encode64(xml) }
      )

      response_xml = Base64.decode64(
        response.body[:submit_query_response][:return]
      )

      ResponseParser.new(response_xml).parse
    end
  end
end
