class AddFieldsToProviderEducation < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_educations, :suite, :string
    add_column :provider_educations, :country, :string
    add_column :provider_educations, :county, :string
  end
end
