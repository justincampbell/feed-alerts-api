require 'rails_helper'

RSpec.describe FeedsController do
  describe "GET index" do
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

  describe "POST create" do
    let(:user) { create(:user) }

    let(:kind) { "rss" }
    let(:url) { "http://example.com/feed.xml" }
    let(:name) { "Feed Name" }
    let(:token) { user.sessions.create.token }

    let(:headers) {
      { "Authorization" => "Bearer #{token}" }
    }

    let(:feed_response) {
      double(FeedResponse, title: name)
    }

    before do
      allow_any_instance_of(Fetcher)
        .to receive(:fetch)
        .and_return(feed_response)
    end

    it "creates a feed created by this user and queues a job" do
      expect(FeedCheckJob).to receive(:perform_later)

      post "/feeds", headers: headers, params: {
        _jsonapi: {
          data: {
            type: "feeds",
            attributes: {
              kind: kind,
              url: url
            }
          }
        }
      }

      expect(response.status).to eq(201)

      feed = Feed.first
      expect(feed.created_by).to eq(user)

      expect(parsed_response).to include_json(
        data: {
          id: feed.id.to_s,
          type: "feeds",
          attributes: {
            kind: kind,
            url: url,
            name: name
          }
        }
      )
    end

    context "without an auth header" do
      it "returns forbidden" do
        post "/feeds", params: {
          _jsonapi: {
            data: {
              type: "feeds",
              attributes: {
                kind: kind,
                url: url
              }
            }
          }
        }

        expect(response.status).to eq(403)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Forbidden" }]
        )
      end
    end

    context "with an invalid feed for the given kind" do
      before do
        allow_any_instance_of(Feed)
          .to receive(:fetch)
          .and_raise(Feedjira::NoParserAvailable)
      end

      it "returns a JSON error" do
        post "/feeds", headers: headers, params: {
          _jsonapi: {
            data: {
              type: "feeds",
              attributes: {
                kind: kind,
                url: url
              }
            }
          }
        }

        expect(response.status).to eq(422)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Not a valid XML feed" }]
        )
      end
    end

    context "with an invalid URL" do
      before do
        allow_any_instance_of(Feed)
          .to receive(:fetch)
          .and_raise(Errno::ECONNREFUSED)
      end

      it "returns a JSON error" do
        post "/feeds", headers: headers, params: {
          _jsonapi: {
            data: {
              type: "feeds",
              attributes: {
                kind: kind,
                url: "foo"
              }
            }
          }
        }

        expect(response.status).to eq(422)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Not a valid URL" }]
        )
      end
    end

    context "with a URL that already exists" do
      before do
        create :feed, url: url
      end

      it "returns a JSON error" do
        post "/feeds", headers: headers, params: {
          _jsonapi: {
            data: {
              type: "feeds",
              attributes: {
                kind: kind,
                url: url
              }
            }
          }
        }

        expect(response.status).to eq(403)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Url has already been taken" }]
        )
      end
    end
  end
end
