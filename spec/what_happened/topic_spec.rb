require 'spec_helper'

describe WhatHappened::Topic do
  let(:event_name) { "create" }
  let(:model_class) { double("model_class") }
  let(:topic) { WhatHappened::Topic.new(model_class, event_name) }
  let(:version) { double("version") }
  let(:model_instance) { double("model_instance") }
  let(:item_type) { double("item_type") }
  let(:changeset) { {  something: ""  } }

  before do
    allow(version).to receive(:item) { model_instance }
    allow(version).to receive(:item_type) { item_type }
    allow(item_type).to receive(:constantize) { model_class }
    allow(version).to receive(:event) { event_name }
    allow(version).to receive(:changeset) { changeset }
  end


  describe "#applies?" do
    subject { topic.applies?(version) }
    context "when model_class and event name match" do
      it { is_expected.to be true }
    end

    context "when current event name differs from event's event name" do
      before { allow(version).to receive(:event) { "update" } }
      it { is_expected.to be false }
    end

    context "when current model class differs from event's model class" do
      before do
        allow(version).to receive(:item_type) { double("other class").as_null_object }
      end
      it { is_expected.to be false }
    end
  end

  describe "#skip_attributes" do
    let(:skipped_attributes) { [ :created_at, :updated_at ] }
    let(:event_name) { "update" }

    before do
      topic.skip_attributes(*skipped_attributes)
    end

    subject { topic.applies?(version) }

    context "when skipped_attributes is an array" do
      let(:skipped_attributes) { [ [:created_at, :updated_at] ] }
      let(:changeset) { { "created_at" => [], "updated_at" => [] } }

      it { is_expected.to be false }
    end

    context "when skipped attributes include all changed attributes" do
      let(:changeset) { { "created_at" => [], "updated_at" => [] } }
      it { is_expected.to be false }
    end

    context "when skipped attributes intersects with changed_attributes" do
      let(:changeset) { { "created_at" => [], "name" => [] } }
      it { is_expected.to be true }
    end

    context "when skipped attributes does not overlap with changed_attributes" do
      let(:changeset) { { "name" => [] } }
      it { is_expected.to be true }
    end
  end
end
