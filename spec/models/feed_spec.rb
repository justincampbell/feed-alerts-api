require 'rails_helper'

RSpec.describe Feed do
  subject(:feed) { build(:feed) }

  it "is valid" do
    expect(feed).to be_valid
  end

  it "valides presence of name" do
    feed.name = nil
    expect(feed).to_not be_valid
  end

  describe "#url" do
    context "when nil" do
      before { feed.url = nil }
      it { is_expected.to_not be_valid }
    end

    context "when not a valid URL" do
      before { feed.url = "foo bar" }
      it { is_expected.to_not be_valid }
    end
  end

  describe "#fetch" do
    subject(:fetch) { feed.fetch }

    let(:feed_response) { double }

    before do
      allow(feed.fetcher)
        .to receive(:fetch)
        .and_return(feed_response)
    end

    it "fetches the feed and returns a feed response" do
      expect(fetch).to eq(feed_response)
    end
  end

  describe "#fetcher" do
    subject(:fetcher) { feed.fetcher }

    it "returns a fetcher with the URL set" do
      expect(fetcher.url).to eq(feed.url)
    end
  end
end
