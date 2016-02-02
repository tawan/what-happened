class MembershipsController < ApplicationController
  before_filter :authorize

  def create
    @group = Group.find(params[:group_id])
    @group.users << current_user
    redirect_to group_path(@group)
  end

  def update
    @membership = Membership.find params[:id]
    @membership.update_attributes(params[:membership].permit(:organizer))
    redirect_to group_path(@membership.group)
  end
end
