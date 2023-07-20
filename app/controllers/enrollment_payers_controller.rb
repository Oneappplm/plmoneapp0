class EnrollmentPayersController < ApplicationController
	def add_payer
		@enrollment_payer = EnrollmentPayer.new(name: params[:name])
		if @enrollment_payer.save
			render json: {status: 'success', message: 'Successfully added payer', payor_id: @enrollment_payer.id}
		else
			render json: {status: 'error', message: @enrollment_payer.errors.full_messages.join(', ')}
		end
	end

	def delete_payer
		@enrollment_payer = EnrollmentPayer.find(params[:id])
		if @enrollment_payer.destroy
			render json: {status: 'success', message: 'Successfully deleted payer'}
		else
			render json: {status: 'error', message: @enrollment_payer.errors.full_messages.join(', ')}
		end
	end
end
