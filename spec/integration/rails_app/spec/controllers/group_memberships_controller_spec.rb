require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe GroupMembershipsController, type: :controller do
  let(:group) { create(:group) }
  let(:new_member)  { create(:user) }
  let(:existing_member) { create(:user) }
  before do
    login(new_member.id)
    create(:group_membership, user: existing_member, group: group, organizer: true)
  end

  describe "POST create" do
    it "creates a notification for the group" do
      expect(group.what_happened).to be_empty
      post :create, group_id: group.id
      expect(group.what_happened.size).to be 1
      expect(group.what_happened.first.label).to eq("group_has_new_member")
    end

    it "creates a notification for existing members" do
      expect(existing_member.what_happened).to be_empty
      post :create, group_id: group.id
      expect(existing_member.what_happened.size).to be 1
      expect(existing_member.what_happened.first.label).to eq("one_of_your_groups_has_a_new_member")
    end
  end
end
