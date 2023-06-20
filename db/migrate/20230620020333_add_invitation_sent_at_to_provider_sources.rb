class AddInvitationSentAtToProviderSources < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_sources, :invitation_sent_at, :datetime
  end
end
