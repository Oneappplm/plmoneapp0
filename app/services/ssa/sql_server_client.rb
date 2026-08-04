# frozen_string_literal: true

require "tiny_tds"

module Ssa
  class SqlServerClient
    class ConnectionError < StandardError; end
    class QueryError < StandardError; end

    def self.with_client(database: nil)
      client = new(database: database).client

      yield client
    ensure
      client&.close
    end

    def initialize(database: nil)
      @database = database
    end

    def client
      @client ||= TinyTds::Client.new(
        username: config.username,
        password: config.password,
        host: config.host,
        port: config.port,
        database: @database.presence || config.database,
        timeout: config.timeout,
        login_timeout: config.login_timeout,
        azure: false,
        tds_version: "7.4"
      )
    rescue TinyTds::Error => error
      raise ConnectionError,
            "Unable to connect to SSA SQL Server: #{error.message}"
    end

    def execute(sql)
      result = client.execute(sql)
      rows = result.each(as: :hash, symbolize_keys: true).to_a
      result.cancel

      rows
    rescue TinyTds::Error => error
      raise QueryError,
            "SSA SQL query failed: #{error.message}"
    end

    private

    def config
      Rails.application.config.x.ssa_sql_server
    end
  end
end