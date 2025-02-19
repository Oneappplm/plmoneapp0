class Faq < ApplicationRecord
  validates :questions, :answer, :visible, presence: true
end
