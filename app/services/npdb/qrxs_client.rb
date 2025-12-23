# frozen_string_literal: true

require 'savon'

module Npdb
  class QrxsClient
    def self.client
      @client ||= Savon.client(
        wsdl: Rails.application.credentials.dig(:npdb, :wsdl),
        ssl_verify_mode: :none,
        log: true,
        pretty_print_xml: true,
        open_timeout: 30,
        read_timeout: 60
      )
    end
  end
end
