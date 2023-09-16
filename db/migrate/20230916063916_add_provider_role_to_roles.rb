class AddProviderRoleToRoles < ActiveRecord::Migration[7.0]
  def change
    Role.find_or_create_by!(name: 'Provider')
  end
end
