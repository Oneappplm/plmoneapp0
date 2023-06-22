class UpdateDefaultSettingsClientName < ActiveRecord::Migration[7.0]
  def change
    Setting.update_setting({ client_name: 'plmhealthoneapp' })
  end
end
