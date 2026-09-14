class AddNewFieldsToProviderEducation < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_educations, :current_program_director_flag, :boolean
  end
end
