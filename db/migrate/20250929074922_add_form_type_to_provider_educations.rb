class AddFormTypeToProviderEducations < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_educations, :form_type, :string
  end
end
