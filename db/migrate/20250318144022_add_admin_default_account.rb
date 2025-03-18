class AddAdminDefaultAccount < ActiveRecord::Migration[7.0]
  def change
    Admin.create(email: "admin1@plmhealth.com", password: "68V5HgaMC") unless Admin.exists?(email: "admin1@plmhealth.com")
  end
end
