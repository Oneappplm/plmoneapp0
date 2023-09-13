class Setting < ApplicationRecord
	mount_uploader :logo_file, ImageUploader

	class << self
		def update_setting(params)
			setting = Setting.take || Setting.new
			setting.update(params)
		end
	end

	def plmhealthoneapp? = client_name == 'plmhealthoneapp'
	def hvhs? = client_name == 'hvhs'
	def qualifacts? = client_name == 'qualifacts'
  def cignahealth? = client_name == 'cignahealth'
end