class AddOtpFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :otp_token, :string
    add_column :users, :otp_code, :string
    add_column :users, :otp_code_expires_at, :datetime
  end
end
