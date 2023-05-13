class AddEncoderReferencedToProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :providers, :encoded_by, :string
    add_column :providers, :updated_by, :string
  end
end
