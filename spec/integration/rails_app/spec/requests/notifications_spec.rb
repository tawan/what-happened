require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe "Notifications", type: :request do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  before do
    post sessions_path, user: { name: user.name }
  end

  describe "creating a new group membership" do
    let!(:member) { create(:member, group: group) }

    before do
      post group_memberships_path(group)
    end

    it "renders a welcome message" do
      get group_path(group)
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/welcomes a new member named .*#{user.name}.*/)
    end

    it "renders a notification for each group member" do
      get user_notifications_path(member)
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/welcomes a new member named .*#{user.name}.*/)
    end
  end

  describe "creating a new meeting" do
    let!(:member) { create(:member, group: group) }

    it "sends a notification to group members" do
      post(
        group_meetings_path(group),
        meeting: attributes_for(:meeting, group_id: group.id))
      expect(response).to have_http_status(:redirect)

      get user_notifications_path(member)
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/scheduled a new meeting/)
    end
  end

  describe "updating meeting" do
    let(:meeting) { create(:meeting) }
    let!(:participant) { create(:participant, meeting: meeting) }

    it "sends a notification to meeting participants" do
      patch(
        group_meeting_path(meeting.group, meeting),
        meeting: { starts_at: Time.now.to_s })

      get user_notifications_path(participant)
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/meeting .* has been updated/)
    end
  end
end
