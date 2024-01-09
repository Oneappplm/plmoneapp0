class AddAttrToDirectorProvider < ActiveRecord::Migration[7.0]
  def change
    add_column :director_providers, :status, :string
    add_column :director_providers, :description, :string
    add_column :director_providers, :signature_upload, :string
  end
end
