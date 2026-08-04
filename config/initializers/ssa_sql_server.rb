# frozen_string_literal: true

Rails.application.config.x.ssa_sql_server = ActiveSupport::OrderedOptions.new

Rails.application.config.x.ssa_sql_server.host = "127.0.0.1"
Rails.application.config.x.ssa_sql_server.port = 1433
Rails.application.config.x.ssa_sql_server.database = "DeathMaster"
Rails.application.config.x.ssa_sql_server.username = "sa"

# Replace this with your local SQL Server password.
Rails.application.config.x.ssa_sql_server.password = "MyStrongPass@2026"

Rails.application.config.x.ssa_sql_server.timeout = 30
Rails.application.config.x.ssa_sql_server.login_timeout = 30