class CreatePeerRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :peer_recommendations do |t|
      t.references :provider, null: false, foreign_key: true
      t.boolean :allow_recommendation, default: false
      t.string :recommendation
      t.string :document
      t.string :notes

      t.timestamps
    end
  end
end
