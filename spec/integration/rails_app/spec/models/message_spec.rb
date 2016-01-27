require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe Message, type: :model do
  let(:sender) { create(:user, name: "Marvin") }
  let(:recipient) { create(:user, name: "John") }
  subject { Message.paper_trail_enabled_for_model? }

  it { is_expected.to be true }

  describe "create" do
    before do
      mount_new_what_happened_config.specify do
        creating_message do
          notifies { |message| message.recipient }
        end
      end
    end

    it "creates a notification" do
      expect(WhatHappened::Notification.all).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(WhatHappened::Notification.all.length).to be 1
      notification = WhatHappened::Notification.first
      expect(notification.recipient.id).to eq(recipient.id)
    end
  end

  describe "update" do
    before do
      mount_new_what_happened_config.specify do
        updating_message do
          notifies { |message| message.recipient }
        end
      end
    end

    it "creates a notification" do
      m = create(:message, sender: sender, recipient: recipient)
      expect(WhatHappened::Notification.all).to be_empty
      m.update_attribute(:text, "He, gibt's was Neues?")
      expect(WhatHappened::Notification.all.length).to be 1
      notification = WhatHappened::Notification.first
      expect(notification.recipient.id).to eq(recipient.id)
    end
  end
end
