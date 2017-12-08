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
end
