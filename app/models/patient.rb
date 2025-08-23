class Patient < ApplicationRecord
  belongs_to :doctor
  has_many :invoices, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :first_name, :last_name, :dob, :medical_history, :emergency_contact, :gender, :email_address, :phone_number, :insurance_information, :address, :next_appointment, :last_visit_date, :current_medications, :allergies, presence: true

  # validates :active, inclusion: { in: [true, false] } 

  def full_name
    "#{first_name} #{last_name}"
  end
end
