require 'rails_helper'

RSpec.describe Preview do
  subject(:preview) { described_class.new(text) }

  let(:text) { "text" }

  describe "#id" do
    it "is a UUID" do
      expect(preview.id).to match(/\A(\h{32}|\h{8}-\h{4}-\h{4}-\h{4}-\h{12})\z/)
    end

    it "is memoized" do
      expect(preview.id).to eq(preview.id)
    end

    it "is random" do
      expect(preview.id).to_not eq(Preview.new(nil).id)
    end
  end

  describe "#text" do
    subject { preview.text }
    it { is_expected.to eq(text) }
  end
end
