class EnrollmentGroupsController < ApplicationController
	before_action :set_pagination_params, only: [:new_user, :edit_user, :new_group, :edit_enrollment_group]

	def index
		@enrollment_group = Group.all
	end

# GROUP
def new_group
  if request.post?
    @enrollment_group = EnrollmentGroup.new(group_params)
    if @enrollment_group.save
      redirect_to new_group_enrollments_path, notice: 'Group has been successfully created.' and return
    end
  else
    @enrollment_group = EnrollmentGroup.new
  end
end

def edit_enrollment_group
  @enrollment_group = EnrollmentGroup.find params[:id]
  if	request.patch?
    if @enrollment_group.update(group_params)

      redirect_to new_group_enrollments_path, notice: "#{group.name} has been successfully updated." and return
    end
  end
  @enrollment_group = EnrollmentGroup.where(from_source: 'enrollment').paginate(per_page: 10, page: params[:page] || 1)
  render 'new_group'
end

def delete_enrollment_group
  group = EnrollmentGroup.find params[:id]
  if user.destroy
    redirect_to new_group_enrollments_path, notice: "#{group.name} has been deleted."
  else
    redirect_to new_group_enrollments_path, alert: 'Something went wrong'
  end

protected

def group_params
  params.require(:group).permit(
    :name, :email, :phone, :fax, :address, :city, :state, :zip, :status
  )
end

end

end