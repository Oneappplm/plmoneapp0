class ChangeSubmitAndResponseDateInProviderNpdbs < ActiveRecord::Migration[7.0]
  def change
    change_column :provider_npdbs, :submit_date, :date, using: 'submit_date::date'
    change_column :provider_npdbs, :response_date, :date, using: 'response_date::date'
  end
end
