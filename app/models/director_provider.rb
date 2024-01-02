class DirectorProvider < ApplicationRecord
  belongs_to :user
  belongs_to :virtual_review_committee
end
