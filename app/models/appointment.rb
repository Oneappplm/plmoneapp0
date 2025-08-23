class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient
  
  has_many :invoices, dependent: :destroy

  enum status: { scheduled: "Scheduled", completed: "Completed", cancelled: "Cancelled" }

  validates :appointment_date, :reason, presence: true
  validate :appointment_date_cannot_be_in_the_past

  def appointment_date_cannot_be_in_the_past
    if appointment_date.present? && appointment_date < Date.today
      errors.add(:appointment_date, "cannot be in the past")
    end    
  end
end

