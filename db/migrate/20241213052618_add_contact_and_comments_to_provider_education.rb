class AddContactAndCommentsToProviderEducation < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_educations, :contact, :string
    add_column :provider_educations, :comments, :text
    add_column :provider_educations, :show_on_tickler, :boolean, default: false
  end
end
