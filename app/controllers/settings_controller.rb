class SettingsController < ApplicationController
	def index
		@setting = Setting.take || Setting.new
		render 'pages/settings'
	end
	def create
		@setting = Setting.new(setting_params)
		if @setting.save
			redirect_to settings_path, notice: "Successfully Updated."
		else
			redirect_to settings_path, alert: "Something went wrong."
		end
	end

	def update
		setting_params[:enable_otp] = setting_params[:enable_otp] == 'YES'
		@setting = Setting.find(params[:id])

		if @setting.update(setting_params)
			@setting.update_columns(enable_otp: setting_params[:enable_otp] == 'YES')
			redirect_to settings_path, notice: "Successfully Updated."
		else
			redirect_to settings_path, alert: "Something went wrong."
		end
	end

	protected
	def setting_params
		params.require(:setting).permit(:theme_color, :font_style, :logo_file, :dark_mode, :enable_otp)
	end
end
