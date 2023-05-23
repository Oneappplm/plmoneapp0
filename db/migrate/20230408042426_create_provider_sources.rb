class CreateProviderSources < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_sources do |t|
     
      t.timestamps
    end
  end
end
