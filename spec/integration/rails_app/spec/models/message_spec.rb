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

    it "creates a version" do
      expect(PaperTrail::Version.all).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(PaperTrail::Version.all.length).to be 1
      version = PaperTrail::Version.first
      expect(version.item.id).to eq(m.id)
    end

    it "creates a notification" do
      expect(recipient.notifications).to be_empty
      m = create(:message, sender: sender, recipient: recipient)
      expect(recipient.notifications.length).to be 1
    end
  end
end