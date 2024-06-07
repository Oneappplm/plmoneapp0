class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  scope :unread, -> { where(read_at: nil) }
  
  def unread?
    read_at.nil?
  end
end
