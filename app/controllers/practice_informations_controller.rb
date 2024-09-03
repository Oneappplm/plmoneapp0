class PracticeInformationsController < ApplicationController
    def create
      @practice_information = PracticeInformation.new(practice_information_params)
      
      if @practice_information.save
        redirect_to success_path, notice: 'Practice Information saved successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def practice_information_params
      params.require(:practice_information).permit(:address)
    end  
end
