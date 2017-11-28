require 'rails_helper'

RSpec.describe FeedsController do
  describe "#index" do
    before do
      create :feed, name: "Foo"
      create :feed, name: "Bar"
      create :feed, name: "Baz"
    end

    context "without a query" do
      before { get "/feeds" }

      it "returns no data" do
        expect(parsed_response).to include_json(
          data: []
        )
      end
    end

    context "with a query" do
      before { get "/feeds", params: { filter: { query: query } } }

      context "partial match" do
        let(:query) { "Ba" }

        it "returns matches" do
          expect(parsed_response['data'].count).to eq(2)
          expect(parsed_response).to include_json(
            data: [
              { attributes: { name: "Bar" } },
              { attributes: { name: "Baz" } }
            ]
          )
        end
      end

      context "case insensitive" do
        let(:query) { "ba" }

        it "returns matches" do
          expect(parsed_response['data'].count).to eq(2)
          expect(parsed_response).to include_json(
            data: [
              { attributes: { name: "Bar" } },
              { attributes: { name: "Baz" } }
            ]
          )
        end
      end
    end
  end

  describe "#preview" do
    let(:feed) { create(:feed) }
    let(:params) { }

    let(:feed_response) {
      double(FeedResponse, items: feed_item, most_recent_item: feed_item)
    }
    let(:feed_item) {
      double(FeedItem, text: "lol")
    }

    before do
      allow_any_instance_of(Feed)
        .to receive(:fetch)
        .and_return(feed_response)
    end

    it "fetches a preview and returns it with the given options" do
      get "/feeds/#{feed.id}/preview"
      expect(parsed_response).to include_json(
        data: {
          attributes: {
            text: "lol"
          }
        }
      )
    end
  end
end
