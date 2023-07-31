namespace :group_contacts	do
	desc "populate enrollment_group_id"

	task :populate_enrollment_group_id	=> :environment do
		GroupContact.all.each do |group_contact|
			dco_id = group_contact.group_dco_id
			if dco_id.present?
        group_dco = GroupDco.find_by(id: dco_id)
        if group_dco.present?
          if group_dco.enrollment_group_id.present?
            group_contact.enrollment_group_id = group_dco.enrollment_group_id
            group_contact.save
          end
        end
      end
		end
	end
end