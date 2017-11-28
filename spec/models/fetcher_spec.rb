require 'rails_helper'

RSpec.describe Fetcher do
  subject(:fetcher) { described_class.new(url: url) }

  let(:url) { Faker::Internet.url }

  it "sets the URL" do
    expect(fetcher.url).to eq(url)
  end

  describe "#fetch" do
    subject(:fetch) { fetcher.fetch }

    context "integration tests", :vcr do
      let(:url) { "http://crossfitwc.com/category/wod/feed/" }

      it "returns a feed response" do
        response = fetch
        expect(response.title).to match(/crossfit/i)
      end
    end
  end
end
