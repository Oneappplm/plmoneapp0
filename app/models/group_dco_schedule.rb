# frozen_string_literal: true

class GroupDcoSchedule < ApplicationRecord
	belongs_to :group_dco
	validates_presence_of :day, :start_time, :end_time
end
