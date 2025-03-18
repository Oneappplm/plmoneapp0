class CreateSecurityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :security_logs do |t|
      t.references :trackable, polymorphic: true, null: true
      t.string :activity
      t.integer :severity
      t.string :ip_address
      t.text :details

      t.timestamps
    end
  end
end
