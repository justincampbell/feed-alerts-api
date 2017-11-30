require 'rails_helper'

RSpec.describe Subscription do
  subject(:subscription) { build(:subscription) }

  describe "#include_title" do
    subject(:include_title) { subscription.include_title }

    it "defaults to false" do
      expect(include_title).to eq(false)
    end
  end

  describe "#shorten_common_terms" do
    subject(:shorten_common_terms) { subscription.shorten_common_terms }

    it "defaults to false" do
      expect(shorten_common_terms).to eq(false)
    end
  end
end
