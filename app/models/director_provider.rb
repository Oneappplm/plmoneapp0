class DirectorProvider < ApplicationRecord
  belongs_to :user
  belongs_to :virtual_review_committee
  enum status: ['Final Approval', 'Deny', 'Recommend termination', 'Pending', 'Tabled']
  attribute :description, :string, default: 'Default Description'
  attribute :signature_upload, :string, default: 'Default Signature Upload'
end
