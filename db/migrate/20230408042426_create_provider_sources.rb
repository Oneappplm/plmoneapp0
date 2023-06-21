class CreateProviderSources < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources do |t|
      t.string :status, default: 'draft'
      t.boolean :current_provider_source, default: false
     
      t.timestamps
    end
  end
end
