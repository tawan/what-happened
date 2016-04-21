class MeetingsController < ApplicationController
  before_filter :authorize

  def new
    @group = Group.find(params[:group_id])
  end

  def show
    @meeting = Meeting.find(params[:id])
  end

  def edit
    @meeting = Meeting.find(params[:id])
    @edit = true
    render "meetings/show"
  end

  def create
    params.require(:meeting).permit!
    @group = Group.find(params[:group_id])
    @meeting = Meeting.create(params[:meeting].merge(group: @group, creator: current_user))
    redirect_to group_path(@group)
  end

  def update
    params.require(:meeting).permit!
    @meeting = Meeting.find params[:id]
    @meeting.update_attributes(params[:meeting])
    redirect_to group_meeting_path(@meeting.group_id, @meeting)
  end
end
