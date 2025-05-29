class CustomAudit < Audited::Audit
	def dislay_changes
	  if action.in?(%w[login logout])
    user_name = user&.full_name || "Unknown User"
    timestamp = created_at.in_time_zone('America/Los_Angeles').strftime('%d/%m/%Y %I:%M %p')

    if action == 'login'
      ["<strong>#{user_name}</strong> logged in at <strong style='color: green'>#{timestamp} PT</strong>"]
    elsif action == 'logout'
      ["<strong>#{user_name}</strong> logged out at <strong style='color: green'>#{timestamp} PT</strong>"]
    end
  else
    audited_changes.map do |attribute, changes|
      next if changes.present? && changes[0].nil? && changes[1].nil? || changes[0] == changes[1] || excluded_atts.include?(attribute)

      "<strong>#{attribute}</strong> changed from 
      <strong style='color: red'>#{changes[0]}</strong> to 
      <strong style='color: green'>#{changes[1]}</strong>"
    end.compact
  end
rescue
  []
	end


	def display_source
		if auditable_type == 'Provider'
			auditable&.fullname
		elsif auditable_type == 'EnrollmentProvidersDetail'
			auditable&.enrollment_provider&.full_name
		elsif auditable_type == 'User'
			auditable&.full_name
		else
			"N/A"
		end
	end

	def empty_changes?
		dislay_changes.empty?
	end

	def excluded_atts
		[
			'encrypted_password',
			'logout_on_close',
			'last_logout_on_close',
			'agent_user_id',
			'otp_token',
			'otp_code',
			'otp_code_expires_at'
		]
	end
end