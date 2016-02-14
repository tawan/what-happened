
class ParticipationsController < ApplicationController
  before_filter :authorize

  def create
    @group = Group.find(params[:group_id])
    @meeting = @group.meetings.find(params[:meeting_id])
    @meeting.participants << current_user
    redirect_to group_path(@group)
  end
end
