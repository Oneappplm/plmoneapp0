class Setting < ApplicationRecord
	include ActionView::Helpers::AssetUrlHelper
	mount_uploader :logo_file, ImageUploader

	class << self
		def update_setting(params)
			setting = Setting.take || Setting.new
			setting.update(params)
		end

		def current_logo
			current_setting = Setting.take
			return current_setting.logo_file.url if current_setting.logo_file.present?

			logo_path = if current_setting.qualifacts?
				ActionController::Base.helpers.asset_path('qualifacts-logo.svg') # full url
			else
				ActionController::Base.helpers.asset_path('plm-logo-3.png')
			end

			"#{Figaro.env.domain}/#{logo_path}"
		end
	end

	def plmhealthoneapp? = client_name == 'plmhealthoneapp'
	def hvhs? = client_name == 'hvhs'
	def qualifacts? = client_name == 'qualifacts'
 def cignahealth? = client_name == 'cignahealth'
	def dcs? = client_name == 'dcs'

	def t(key)
		I18n.t("#{client_name}.#{key}")
	end
end
