class EnrollmentGroupDeletedDocLog < ApplicationRecord
  belongs_to :enrollment_group
	before_create :set_title

  KEY_TITLE = {
    w9_file: "W9",
    cp575_file: "CP575/Proof of TIN",
    payer_contracts: "Qualifacts Documents",
    group_type_documents: "Other Group Documents",
    eft_file: "Liability Insurance",
    voided_check_file: "Voided Check",
    specific_type_file: "Articles of Incorporation"
  }
	def deleted_notes = "#{title} #{note} - #{deleted_at.strftime('%B %d, %Y')}"

	def set_title
		self.title = filtered_title_by_key
	end

	def filtered_title_by_key
		"Deleted #{	KEY_TITLE[self.document_key.to_sym] rescue 'document' } with note: "
	end
end
