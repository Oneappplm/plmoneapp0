# frozen_string_literal: true

class Admins::SessionsController < Devise::SessionsController
  def create
    email = params[:admin][:email]
    ip    = request.remote_ip
    admin = Admin.find_by_email(email)

    if admin && admin.valid_password?(params[:admin][:password])
      clear_counter("mistyped_password:#{admin.email}:#{ip}")
    elsif admin
      count = increment_counter("mistyped_password:#{admin.email}:#{ip}")
      log_password_attempts(admin, count) if count >= 3
    else
      count = increment_counter("invalid_login:#{email}:#{ip}")
      log_repeated_failures(email, count) if count >= 3
    end

    super
  end

  private

  def increment_counter(key)
    count = (Rails.cache.read(key) || 0) + 1
    Rails.cache.write(key, count, expires_in: 30.minutes)
    count
  end

  def clear_counter(key)
    Rails.cache.delete(key)
  end

  def log_password_attempts(admin, count)
    SecurityLog.create(
      trackable: admin,
      activity: "Multiple password attempts",
      severity: :low,
      ip_address: request.remote_ip,
      details: "#{admin.full_name} mistyped password #{count} times for account with email #{admin.email}"
    )
  end

  def log_repeated_failures(email, count)
    SecurityLog.create(
      trackable_type: "Admin",
      activity: "Repeated login failures",
      severity: :medium,
      ip_address: request.remote_ip,
      details: "#{count} login attempts with invalid credentials (#{email})"
    )
  end
end
