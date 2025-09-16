class ChangeSubmitAndResponseDateInProviderNpdbs < ActiveRecord::Migration[7.0]
  def change
    change_column :provider_npdbs, :submit_date, :date, using: "NULLIF(submit_date, '')::date"
    change_column :provider_npdbs, :response_date, :date, using: "NULLIF(response_date, '')::date"
  end
end
