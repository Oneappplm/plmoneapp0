class Setting < ApplicationRecord
	class << self
		def update_setting(params)
			setting = Setting.take || Setting.new
			setting.update(params)
		end
	end

	def plmhealthoneapp? = client_name == 'plmhealthoneapp'
	def hvhs? = client_name == 'hvhs'
	def qualifacts? = client_name == 'qualifacts'
end