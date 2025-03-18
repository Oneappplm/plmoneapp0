# frozen_string_literal: true

class DeviseCreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :suffix
      t.string :status

      t.boolean :super_admin, default: false

      t.string :user_type
      t.string :user_role, default: "administrator"
      t.string :following_request
      t.string :from_source
      t.string :temporary_password
      t.string :temporary_password_confirmation
      t.string :title
      t.string :api_token
      t.string :otp_token
      t.string :otp_code
      t.datetime :otp_code_expires_at
      t.boolean :logout_on_close, default: false
      t.datetime :last_logout_on_close
      t.boolean :can_access_all_groups
      t.boolean :is_provider_account
      t.string :accessible_provider
      t.string :password_change_status_via_invite
      t.string :security_question
      t.string :security_answer
      t.boolean :assigned_access_only

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Invitable
      t.string     :invitation_token
      t.datetime   :invitation_created_at
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.integer    :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer    :invitations_count, default: 0
      t.index      :invitation_token, unique: true
      t.index      :invited_by_id

      t.timestamps null: false
    end

    add_index :admins, :email,                unique: true
    add_index :admins, :reset_password_token, unique: true
    add_index :admins, :confirmation_token,   unique: true
    add_index :admins, :unlock_token,         unique: true
  end
end
