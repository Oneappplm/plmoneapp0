# frozen_string_literal: true

Rails.application.config.x.ssa_sql_server =
  ActiveSupport::OrderedOptions.new

Rails.application.config.x.ssa_sql_server.host =
  ENV.fetch("SSA_SQLSERVER_HOST", "127.0.0.1")

Rails.application.config.x.ssa_sql_server.port =
  ENV.fetch("SSA_SQLSERVER_PORT", "1433").to_i

Rails.application.config.x.ssa_sql_server.database =
  ENV.fetch("SSA_SQLSERVER_DATABASE", "DeathMaster")

Rails.application.config.x.ssa_sql_server.username =
  ENV.fetch("SSA_SQLSERVER_USERNAME", "sa")

Rails.application.config.x.ssa_sql_server.password =
  ENV["SSA_SQLSERVER_PASSWORD"]

Rails.application.config.x.ssa_sql_server.timeout =
  ENV.fetch("SSA_SQLSERVER_TIMEOUT", "30").to_i

Rails.application.config.x.ssa_sql_server.login_timeout =
  ENV.fetch("SSA_SQLSERVER_LOGIN_TIMEOUT", "30").to_i