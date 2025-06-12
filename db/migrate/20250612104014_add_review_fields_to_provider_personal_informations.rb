class AddReviewFieldsToProviderPersonalInformations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_personal_informations, :review_level, :string
    add_column :provider_personal_informations, :recred_due_date, :date
    add_column :provider_personal_informations, :review_date, :date
  end
end
