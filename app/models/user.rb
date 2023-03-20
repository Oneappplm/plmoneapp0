class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum user_type: {
    vrc_scheduler_staff: 'VRC Scheduler Staff',
    vrc_scheduler_director: 'VRC Scheduler Director',
    client_staff: 'Client Staff',
    client_admin: 'Client Admin'
  }
  validates :first_name, presence: true
  validates :last_name, presence: true
end
