class AddAttachmentsFieldsToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :check_welcome_letter, :boolean, default: false
    add_column :providers, :check_co_caqh, :boolean, default: false
    add_column :providers, :check_mn_caqh_state_release_form, :boolean, default: false
    add_column :providers, :check_mn_caqh_authorization_form, :boolean, default: false
    add_column :providers, :check_caqh_standard_authorization, :boolean, default: false
  end
end
