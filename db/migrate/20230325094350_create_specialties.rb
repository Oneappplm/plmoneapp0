class CreateSpecialties < ActiveRecord::Migration[7.0]
  def change
    create_table :specialties do |t|
      t.string :fch
      t.string :bcbs
      t.string :perform_rx
      t.string :dwihn
      t.string :met_life
      t.string :pharmpix
      t.string :broward_health
      t.string :ochn
      t.string :primary_partner_care
      t.string :sdsu_student_health_services
      t.string :ucamc
      t.string :macomb_country
      t.string :nkcph

      t.timestamps
    end
  end
end
