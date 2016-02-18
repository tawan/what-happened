require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe "Generals user stories", type: :request do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe "GET /" do
    it "works!" do
      get "/"
      expect(response).to have_http_status(200)
      expect(response.body).to match(/Demo - What Happened/)
    end
  end

  describe "sign in" do
    it "works!" do
      post sessions_path, user: { name: user.name }
      get "/"

      expect(response).to have_http_status(200)
      expect(response.body).to match(/Signed in as #{user.name}/)
    end
  end


  describe "sign out" do
    it "works!" do
      delete "/sessions/current"
      get "/"

      expect(response).to have_http_status(200)
      expect(response.body).to match(/Sign in/)
    end
  end

  describe "GET /groups/:id" do
    it "works!" do
      get group_path(group)
      expect(response).to have_http_status(200)
    end
  end

  context "when signed in" do
    before do
      post sessions_path, user: { name: user.name }
    end


    describe "group memberships" do
      it "can be created" do
        post group_memberships_path(group)
        follow_redirect!

        expect(response).to have_http_status(200)
        expect(response.body).to match(/Members.*#{user.name}/m)
      end
    end

    describe "meetings" do
      let(:meeting) { create(:meeting, group: group) }

      it "has a form page" do
        get new_group_meeting_path(group)
        expect(response).to have_http_status(200)
      end

      it "can be created" do
        post(
          group_meetings_path(group),
          meeting: {
            name: "test",
            starts_at: Time.now.to_s,
            ends_at: Time.now.to_s
          })

        follow_redirect!
        expect(response).to have_http_status(200)
        expect(response.body).to match(/test/)
      end

      it "can be edited" do
        get edit_group_meeting_path(group, meeting)
        expect(response).to have_http_status(200)
        expect(response.body).to match(/value="#{meeting.name}"/)
      end

      it "can be updated" do
        put(
          group_meeting_path(group, meeting),
          meeting: {
            name: "new name"
          })

        follow_redirect!
        expect(response).to have_http_status(200)
        expect(response.body).to match(/new name/)
      end

      describe "participation" do
        it "can be created" do
          post group_meeting_participations_path(group, meeting)

          follow_redirect!
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
