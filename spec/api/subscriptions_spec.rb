require 'rails_helper'

RSpec.describe SubscriptionsController do
  let(:user) { create(:user) }
  let(:headers) {
    { "Authorization" => "Bearer #{token}" }
  }
  let(:token) { user.sessions.create.token }

  describe "#create" do
    let(:feed) { create(:feed) }

    it "creates a subscription" do
      post "/subscriptions", headers: headers, params: {
        _jsonapi: {
          data: {
            type: "subscriptions",
            attributes: {
              include_title: true,
              shorten_common_terms: true,
              feed_id: feed.id
            }
          }
        }
      }

      expect(response.status).to eq(201)

      subscription = Subscription.first
      expect(subscription.user).to eq(user)

      expect(parsed_response).to include_json(
        data: {
          id: subscription.id.to_s,
          type: "subscriptions",
          attributes: {
            include_title: true,
            shorten_common_terms: true
          }
        },
        included: [
          { type: "feeds", id: feed.id.to_s }
        ]
      )
    end

    context "without an auth header" do
      it "returns forbidden" do
        post "/subscriptions", params: {
          _jsonapi: {
            data: {
              type: "subscriptions",
              attributes: {
                include_title: true,
                shorten_common_terms: true,
                feed_id: feed.id
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

    context "with a duplicate subscription" do
      let(:feed) { create(:feed) }

      before { create(:subscription, feed: feed, user: user) }

      it "returns an error" do
        post "/subscriptions", headers: headers, params: {
          _jsonapi: {
            data: {
              type: "subscriptions",
              attributes: {
                include_title: true,
                shorten_common_terms: true,
                feed_id: feed.id
              }
            }
          }
        }

        expect(response.status).to eq(403)

        expect(parsed_response).to include_json(
          errors: [
            {
              detail: "Feed already subscribed to"
            }
          ]
        )
      end
    end
  end

  describe "#preview" do
    let(:feed) { create(:feed) }

    let(:params) {
      {
        _jsonapi: {
          data: {
            type: "subscriptions",
            attributes: {
              include_title: include_title,
              shorten_common_terms: shorten_common_terms
            },
            relationships: {
              feed: { data: { type: "feeds", id: feed.id.to_s } }
            }
          }
        }
      }
    }

    let(:include_title) { true }
    let(:shorten_common_terms) { false }

    let(:feed_response) { double(FeedResponse, most_recent_item: feed_item) }
    let(:feed_item) { double(FeedItem, title: "title", text: "text") }

    before do
      allow_any_instance_of(Feed)
        .to receive(:fetch)
        .and_return(feed_response)
    end

    it "generates a preview and returns it with the given options" do
      post "/preview", headers: headers, params: params

      expect(parsed_response).to include_json(
        data: {
          attributes: {
            text: "title\ntext"
          }
        }
      )
    end
  end
end
