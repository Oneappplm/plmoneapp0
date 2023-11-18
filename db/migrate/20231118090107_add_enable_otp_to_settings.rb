class AddEnableOtpToSettings < ActiveRecord::Migration[7.0]
  def change
				add_column :settings, :enable_otp, :boolean, default: true
  end
end
