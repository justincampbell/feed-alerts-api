require 'rails_helper'

RSpec.describe SubscriptionsController do
  before { create(:user) }

  describe "#create" do
    let(:feed) { create(:feed) }

    it "creates a subscription" do
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

      expect(response.status).to eq(201)

      subscription = Subscription.first

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
  end

  context "with a duplicate subscription" do
    let(:feed) { create(:feed) }

    before { create(:subscription, feed: feed, user: User.first) }

    it "returns an error" do
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
        errors: [
          {
            detail: "Feed already subscribed to"
          }
        ]
      )
    end
  end
end
