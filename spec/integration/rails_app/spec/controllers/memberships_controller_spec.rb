require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe MembershipsController, type: :controller do
  let(:group) { create(:group) }
  let(:new_member)  { create(:user) }

  before do
    login(new_member.id)
  end

  describe "POST create" do
    it "creates a notification for the group" do
      expect {
        post :create, group_id: group.id
      }.to notify(group).about(:group_has_new_member)
    end
  end
end
