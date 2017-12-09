require 'rails_helper'

RSpec.describe WebhooksController do
  describe "#twilio" do
    let(:params) {
      {
        Body: body,
        From: from
      }
    }

    let(:body) { "ping" }
    let(:from) { "+12155551212" }

    it "returns a TwiML response" do
      post "/webhooks/twilio",
        params: params

      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/xml")
    end

    context "with stop" do
      let(:body) { "stop" }

      it "returns no content" do
        post "/webhooks/twilio",
          params: params

        expect(response.status).to eq(204)
        expect(response.body).to eq("")
      end
    end
  end
end
