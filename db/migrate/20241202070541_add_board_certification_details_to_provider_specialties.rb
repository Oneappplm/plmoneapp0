class AddBoardCertificationDetailsToProviderSpecialties < ActiveRecord::Migration[7.0]
  def change
    add_column :provider_specialties, :planning_to_take_board_exam_flag, :boolean
    add_column :provider_specialties, :board_exam_explanation, :string
  end
end
