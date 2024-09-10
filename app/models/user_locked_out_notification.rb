class UserLockedOutNotification < Noticed::Base
  # Add delivery methods (e.g., database, email, Slack)
  deliver_by :database
  # or any other methods you're using
end