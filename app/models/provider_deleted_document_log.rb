class ProviderDeletedDocumentLog < ApplicationRecord
	belongs_to :provider
	before_create :set_title

	def deleted_notes = "#{title} #{note} - #{deleted_at.strftime('%B %d, %Y')}"

	def set_title
		self.title = filtered_title_by_key
	end

	def filtered_title_by_key
		"Deleted #{	self.document_key.titleize.remove("File").strip rescue 'document' } with note: "
	end
end
