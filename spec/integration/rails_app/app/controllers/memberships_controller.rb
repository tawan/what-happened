class MembershipsController < ApplicationController
  before_filter :authorize

  def create
    @group = Group.find(params[:group_id])
    @group.members << current_user
    redirect_to group_path(@group)
  end
end
