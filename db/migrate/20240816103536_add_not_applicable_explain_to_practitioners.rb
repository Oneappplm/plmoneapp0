class AddNotApplicableExplainToPractitioners < ActiveRecord::Migration[7.0]
  def change
    add_column :practitioners, :not_applicable_explain, :text
  end
end
