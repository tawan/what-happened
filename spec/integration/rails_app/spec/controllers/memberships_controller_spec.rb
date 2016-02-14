require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe MembershipsController, type: :controller do
  let(:group) { create(:group) }
  let(:new_member)  { create(:user) }
  let(:existing_member) { create(:user) }
  let!(:membership) { create(:membership, user: existing_member, group: group, organizer: true) }

  before do
    login(new_member.id)
  end

  describe "POST create" do
    it "creates a notification for the group" do
      expect {
        post :create, group_id: group.id
      }.to notify(group).about(:group_has_new_member)
    end

    it "creates a notification for existing members" do
      expect {
        post :create, group_id: group.id
      }.to notify(existing_member).about(:one_of_your_groups_has_a_new_member)
    end
  end

  describe "PUT update" do
    it "creates a notification for the group" do
      expect {
        put :update, group_id: group.id, id: membership.id, membership: { organizer: false }
      }.to notify(group).about(:organizer_changed)
    end

    context "when a skipped attribute is changed" do
      it "does not create a notification for the group" do
        expect {
          put :update, group_id: group.id, id: membership.id, membership: { organizer: true }
        }.not_to notify(group)
      end
    end
  end
end
