class UpdateRoleSlugViewerToProvider < ActiveRecord::Migration[7.0]
  def change
    Role.where(slug: 'viewer').update_all(slug: 'provider')
  end
end
