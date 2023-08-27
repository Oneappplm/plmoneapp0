class EgdLog < ApplicationRecord
	belongs_to	:enroll_groups_detail

	def display_summary = "#{self.created_at.strftime('%m/%d/%Y')}: Application Status changed to #{self.status.titleize}"
  end