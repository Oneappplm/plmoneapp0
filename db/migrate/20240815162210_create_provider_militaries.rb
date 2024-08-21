class CreateProviderMilitaries < ActiveRecord::Migration[7.0]
  def self.up
    create_table :provider_militaries, id: false do |t|
      t.primary_key    :provider_military_id
      t.references     :provider_attest
      t.string         :last_location
      t.string         :discharge_rank
      t.string         :branch
      t.datetime       :start_date
      t.datetime       :end_date
      t.boolean        :honorable_discharge_flag
      t.text           :discharge_explanation
      t.boolean        :reserve_guard_flag
      t.boolean        :court_martial_flag
      t.text           :court_martial_explanation
      t.string         :active_duty

      t.timestamps
    end
  end

  def self.down
    drop_table :provider_militaries
  end
end
