class AddEnrollmentProvidersDetailToFollowUps < ActiveRecord::Migration[7.0]
  def change
    add_reference :follow_ups, :enrollment_providers_detail, foreign_key: true, index: true
  end
end