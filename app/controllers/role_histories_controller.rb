class RoleHistoriesController < ApplicationController
  def index
    @histories = CustomAudit.where(auditable_type: 'User', action: 'update').order(id: :desc)
  end
end
