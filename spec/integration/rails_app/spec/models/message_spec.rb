require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe Message, type: :model do
  let(:sender) { create(:user, name: "Marvin") }
  let(:recipient) { create(:user, name: "John") }
  subject { Message.paper_trail_enabled_for_model? }

  before do
    mount_new_what_happened_config.specify do
      creating_message do
        sends_notification :new_message_in_inbox do
          to { |message| message.recipient }
        end
      end
    end
  end

  it { is_expected.to be true }

  describe "create" do
    before do
      mount_new_what_happened_config.specify do
        creating_message do
          sends_notification :new_message_in_inbox do
            to { |message| message.recipient }
          end
        end
      end
    end

    it "creates a notification" do
      expect(WhatHappened::Notification.all).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(recipient.what_happened.all.length).to be 1
    end
  end

  describe "update" do
    before do
      mount_new_what_happened_config.specify do
        updating_message do
          sends_notification :message_in_inbox_has_been_updated do
            to { |message| message.recipient }
          end
        end
      end
    end

    it "creates a notification" do
      m = create(:message, sender: sender, recipient: recipient)
      expect(WhatHappened::Notification.all).to be_empty
      m.update_attribute(:text, "He, gibt's was Neues?")
      expect(recipient.what_happened.all.length).to be 1
    end
  end

  describe "destroy" do
    before do
      mount_new_what_happened_config.specify do
        destroying_message do
          sends_notification :message_has_been_deleted do
            to { |message| message.recipient }
          end
        end
      end
    end

    it "creates a notification" do
      m = create(:message, sender: sender, recipient: recipient)
      expect(WhatHappened::Notification.all).to be_empty
      m.destroy
      expect(recipient.what_happened.all.length).to be 1
    end
  end
end
