class CreateRvaInformations < ActiveRecord::Migration[7.0]
  def change
    create_table :rva_informations do |t| # This is the table creation part
      t.string :tab
      t.string :send_request
      t.string :requested_by
      t.date :requested_date
      t.string :requested_method
      t.decimal :required_fee_amount, precision: 10, scale: 2
      t.string :check_payable_to
      t.boolean :include_delineation, default: false
      t.boolean :check_generated
      t.boolean :received_status
      t.string :received_by
      t.date :received_date
      t.text :comments
      t.string :source_name
      t.date :source_date
      t.string :status
      t.boolean :adverse_action
      t.text :other_details
      t.text :adverse_action_comments
      t.text :adverse_action_status
      t.string :verification_status
      t.boolean :in_good_standing, default: false
      t.string :error_type
      t.text :error_comments
      t.string :correct_info_selected
      t.string :correct_info_text
      t.string :notification_status
      t.date :verification_date
      t.string :verifier
      t.text :verification_comments
      t.string :audit_reason
      t.text :audit_reason_comments
      t.boolean :audit_status
      t.date :audit_date
      t.string :auditor
      t.text :audit_comments

      t.timestamps
    end
  end
end
