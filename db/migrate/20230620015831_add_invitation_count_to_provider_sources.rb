class AddInvitationCountToProviderSources < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_sources, :invitation_count, :integer, default: 0
  end
end
