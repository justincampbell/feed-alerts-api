require 'rails_helper'

RSpec.describe UsersController do
  let(:auth_user) { create(:user, :admin) }
  let(:headers) {
    { "Authorization" => "Bearer #{token}" }
  }
  let(:token) { auth_user.sessions.create.token }

  describe "#index" do
    let!(:users) { create_list(:user, 3) }

    it "returns the list of users" do
      get "/users", headers: headers

      expect(parsed_response['data'].length).to eq(User.count)
      expect(parsed_response).to include_json(
        data: users.map { |user| { id: user.id.to_s } }
      )
    end

    context "when not an admin" do
      let(:auth_user) { create(:user) }

      it "renders a 404" do
        get "/users", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context "when not authenticated" do
      let(:headers) { {} }

      it "renders a 404" do
        get "/users", headers: headers
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#show" do
    let!(:user) { create(:user) }
    let!(:event) { create(:event, resource: user) }

    it "returns the user with events" do
      get "/users/#{user.id}", headers: headers

      expect(parsed_response).to include_json(
        data: {
          type: "users",
          id: user.id.to_s,
          attributes: {
            admin: user.admin?,
            sms_number: user.sms_number
          },
          relationships: {
            events: {
              data: [
                {
                  type: "events",
                  id: event.id.to_s
                }
              ]
            }
          }
        },
        included: [
          {
            type: "events",
            id: event.id.to_s,
            attributes: {}
          }
        ]
      )
    end

    context "when not an admin" do
      let(:auth_user) { create(:user) }

      it "renders a 404" do
        get "/users/#{user.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context "when not authenticated" do
      let(:headers) { {} }

      it "renders a 404" do
        get "/users/#{user.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end
  end
end
