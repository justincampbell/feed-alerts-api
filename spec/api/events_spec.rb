require 'rails_helper'

RSpec.describe EventsController do
  let(:user) { create(:user, :admin) }
  let(:headers) {
    { "Authorization" => "Bearer #{token}" }
  }
  let(:token) { user.sessions.create.token }

  describe "#index" do
    before do
      create_list :event, 3
    end

    it "generates a preview and returns it with the given options" do
      get "/events", headers: headers

      expect(parsed_response['data'].length).to eq(Event.count)
      expect(parsed_response).to include_json(
        data: Event.all.map { |event| { id: event.id.to_s } }
      )
    end

    context "when not an admin" do
      let(:user) { create(:user) }

      it "renders a 404" do
        get "/events", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context "when not authenticated" do
      let(:headers) { {} }

      it "renders a 404" do
        get "/events", headers: headers
        expect(response.status).to eq(404)
      end
    end
  end
end
