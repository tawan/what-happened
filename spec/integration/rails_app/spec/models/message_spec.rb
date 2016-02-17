require File.expand_path('../../rails_helper', __FILE__)

RSpec.describe Message, type: :model do
  let(:sender) { create(:user, name: "Marvin") }
  let(:recipient) { create(:user, name: "John") }
  subject { Message.paper_trail_enabled_for_model? }

  with_notification_routing do
    creating_message do
      sends_notification :new_message_in_inbox do
        to { |message| message.recipient }
      end
    end
  end

  it { is_expected.to be true }

  describe "create" do
    with_notification_routing do
      creating_message do
        sends_notification :new_message_in_inbox do
          to { |message| message.recipient }
        end
      end
    end

    it "creates a notification" do
      expect {
        create(:message, sender: sender, recipient: recipient)
      }.to notify(recipient).about(:new_message_in_inbox)
    end
  end

  describe "update" do
    with_notification_routing do
      updating_message do
        sends_notification :message_in_inbox_has_been_updated do
          to { |message| message.recipient }
        end
      end
    end

    it "creates a notification" do
      m = create(:message, sender: sender, recipient: recipient)
      expect {
        m.update_attribute(:text, "He, gibt's was Neues?")
      }.to notify(recipient).about(:message_in_inbox_has_been_updated)
    end
  end

  describe "destroy" do
    with_notification_routing do
      destroying_message do
        sends_notification :message_has_been_deleted do
          to { |message| message.recipient }
        end
      end
    end

    it "creates a notification" do
      m = create(:message, sender: sender, recipient: recipient)
      expect { m.destroy }.to notify(recipient).about(:message_has_been_deleted)
    end
  end
end
