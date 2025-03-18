class SecurityLog < ApplicationRecord
  belongs_to :trackable, polymorphic: true, optional: true

  enum severity: { low: 0, medium: 1, high: 2, critical: 3 }

  validates :activity, presence: true
  validates :severity, presence: true

  def severity_color
    case severity
    when 'low'
      'text-info'
    when 'medium'
      'text-warning'
    when 'high'
      'text-danger'
    when 'critical'
      'text-danger font-weight-bold'
    end
  end
end
