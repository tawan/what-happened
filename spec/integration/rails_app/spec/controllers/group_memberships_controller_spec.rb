require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe GroupMembershipsController, type: :controller do
  let(:group) { create(:group) }
  let(:user)  { create(:user) }
  before do
    mount_new_what_happened_config.specify do
      creating_group_membership do
        notifies { |group_membership| group_membership.group }
        label_as :group_has_new_member
      end
    end

    login(user.id)
  end

  describe "POST create" do
    it "creates a notification" do
      expect(group.what_happened).to be_empty
      post :create, group_id: group.id
      expect(group.what_happened.size).to be 1
      expect(group.what_happened.first.label).to eq("group_has_new_member")
    end
  end
end
