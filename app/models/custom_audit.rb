class CustomAudit < Audited::Audit
	def dislay_changes
			audited_changes.map do |attribute, changes|
				next if changes[0].nil? && changes[1].nil? || changes[0] == changes[1] || ['logout_on_close', 'last_logout_on_close'].include?(attribute)

				"<strong>#{attribute}</strong> changed from <strong style='color: red'>#{changes[0]}</strong> to <strong style='color: green'>#{changes[1]}</strong>"
			end.compact
	end

	def display_source
		if auditable_type == 'Provider'
			auditable&.fullname
		elsif auditable_type == 'EnrollmentProvidersDetail'
			auditable.enrollment_provider.full_name
		elsif auditable_type == 'User'
			auditable&.full_name
		else
			"N/A"
		end
	end

	def empty_changes?
		dislay_changes.empty?
	end
end