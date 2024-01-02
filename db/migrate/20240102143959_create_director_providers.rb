class CreateDirectorProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :director_providers do |t|
      t.references :user, foreign_key: true
      t.references :virtual_review_committee, foreign_key: true

      t.timestamps
    end
  end
end
