require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe MeetingsController, type: :controller do
  let(:group) { create(:group) }
  let(:creator)  { create(:user) }
  let(:another_member) { create(:user) }

  before do
    login(creator.id)
    group.users << creator
    group.users << another_member
  end

  describe "POST create" do
    it "notifies the group's members" do
      expect {
        post :create, group_id: group.id
      }.to notify(another_member).about(:new_meeting_announced)
    end

    it "does not notify the meetings creator" do
      expect {
        post :create, group_id: group.id
      }.not_to notify(creator).about(:new_meeting_announced)
    end
  end

  describe "PUT update" do
    let(:meeting) { create(:meeting, group: group) }
    let(:participant) { create(:participant, meeting: meeting) }

    it "notifies meeting participants" do
      expect {
        put(
          :update,
          group_id: group.id,
          id: meeting.id,
          meeting: { starts_at: Time.now })
      }.to notify(participant).about(:meeting_was_updated)
    end

    context "when skipped attribute has been changed" do
      it "does not notify anyone" do
        expect {
          put(
            :update,
            group_id: group.id,
            id: meeting.id,
            meeting: { description: "new description" })
        }.not_to notify(participant).about(:meeting_was_updated)
      end
    end
  end
end
