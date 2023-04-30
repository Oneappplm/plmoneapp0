class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.string :theme_color
      t.string :font_style
      t.string :logo_file
      t.string :dark_mode, default: 'NO'

      t.timestamps
    end
  end
end
