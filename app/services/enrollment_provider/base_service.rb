class EnrollmentProvider::BaseService < ApplicationService
  attr_reader :enrollment_provider
 
  def initialize(enrollment_provider)
   @enrollment_provider = enrollment_provider
  end
end
