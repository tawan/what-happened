require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe Message, type: :model do
  subject { Message.paper_trail_enabled_for_model? }
  it { is_expected.to be true }

  describe "create" do
    let(:sender) { create(:user, name: "Marvin") }
    let(:recipient) { create(:user, name: "John") }

    it "creates a version" do
      expect(PaperTrail::Version.all).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(PaperTrail::Version.all.length).to be 1
      version = PaperTrail::Version.first
      expect(version.item.id).to eq(m.id)
    end

    it "creates a notification" do
      expect(WhatHappened::Notification.all).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(WhatHappened::Notification.all.length).to be 1
      notification = WhatHappened::Notification.first
      expect(notification.recipient.id).to eq(recipient.id)
    end
  end
end
