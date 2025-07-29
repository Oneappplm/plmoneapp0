class CreateProviderLanguages < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_languages do |t|
      t.integer        :caqh_provider_language_id
      t.references     :provider_attest
      t.integer        :caqh_provider_attest_id
      t.string         :language_type
      t.string         :language_language_name

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_languages
  end
end
