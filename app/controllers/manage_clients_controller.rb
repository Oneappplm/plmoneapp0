class ManageClientsController < ApplicationController

  def new 
    @practitioner = Practitioner.new
  end

  def create 
    @practitioner = Practitioner.new(practitioner_params)

    if @practitioner.save 
      redirect_to action: "index"
    else
      render :new, status: :unprocessable_entity
    end 
  end 

  private
  def practitioner_params
    params.require(:practitioner).permit(:first_name, :middle_name, :last_name, :suffix, :gender, :date_of_birth, :social_security_number,
     :contact_method, :phone_number, :fax_number, :email_address, :address, :suit_or_apt, 
     :additional_address, :city, :country, :state_or_province, :zipcode, :practitioner_type,
     :credentials_committee_date, :credentials_batch_date, :client_batch_name, :client_batch_id,
     :market, :status, :application_method, :availability, :county) 
  end 
end
