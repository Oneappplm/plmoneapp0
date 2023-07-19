class EpdLog < ApplicationRecord
	belongs_to	:enrollment_providers_detail

	def display_summary = "#{self.created_at.strftime('%m/%d/%Y')}: Application Status changed to #{self.status.titleize}"
end
