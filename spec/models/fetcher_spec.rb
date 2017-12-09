require 'rails_helper'

RSpec.describe Fetcher do
  subject(:fetcher) { described_class.new(url: url) }

  let(:url) { Faker::Internet.url }

  it "sets the URL" do
    expect(fetcher.url).to eq(url)
  end

  describe "#cache_key" do
    subject(:cache_key) { fetcher.cache_key }

    it { is_expected.to start_with("fetcher-") }
  end

  describe "#fetch" do
    it "caches the response" do
      expect(Net::HTTP)
        .to receive(:get_response)
        .once
        .and_return(double(body: "test"))

      fetcher.fetch
      fetcher.fetch
    end

    context "integration tests", :vcr do
      let(:url) { "http://crossfitwc.com/category/wod/feed/" }

      it "returns a feed response" do
        response = fetcher.fetch
        expect(response.title).to match(/crossfit/i)
      end
    end
  end
end
