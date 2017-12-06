require 'rails_helper'

RSpec.describe Session do
  subject(:session) { Session.create(user: user) }

  let(:user) { create(:user) }

  describe "#token" do
    subject(:token) { session.token }

    it "generates a token" do
      expect(token).to be_a(String)
      expect(token).to be_present
      expect(token.length).to be >= 32
    end
  end

  describe "#expires_at" do
    subject(:expires_at) { session.expires_at }

    it "is 2 weeks from updated at" do
      expect(expires_at)
        .to be_within(1.minute).of(session.updated_at + 2.weeks)
    end
  end
end
