class Admin < ApplicationRecord
  include UserCommon
  include DynamicRolesInitializer

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable,
         :rememberable, :validatable, :timeoutable
end
