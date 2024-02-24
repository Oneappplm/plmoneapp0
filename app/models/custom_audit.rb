class CustomAudit < Audited::Audit
	def dislay_changes
			audited_changes.map do |attribute, changes|
				next if changes[0].nil? && changes[1].nil?

				"<strong>#{attribute}</strong> changed from <strong style='color: red'>#{changes[0]}</strong> to <strong style='color: green'>#{changes[1]}</strong>"
			end.compact
	end
end