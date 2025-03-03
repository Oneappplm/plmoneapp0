class CreateSpecialtyDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :specialty_details do |t|
      t.string :ranking
      t.string :specialty
      t.boolean :certified
      t.string :certifying_board
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :board_certificate
      t.string :telephone
      t.date :initial_date
      t.date :expiration_date
      t.boolean :ppo_directory
      t.boolean :pos_directory
      t.boolean :provider_directory
      t.boolean :hmo_directory
      t.boolean :board_certified
      t.boolean :certified_eligible
      t.boolean :failed_exam

      t.timestamps
    end
  end
end
