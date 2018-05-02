require 'rails_helper'

RSpec.describe UsersController do
  let(:user) { create(:user, :admin) }
  let(:headers) {
    { "Authorization" => "Bearer #{token}" }
  }
  let(:token) { user.sessions.create.token }

  describe "#index" do
    before do
      create_list :user, 3
    end

    it "returns the list of users" do
      get "/users", headers: headers

      expect(parsed_response['data'].length).to eq(User.count)
      expect(parsed_response).to include_json(
        data: User.all.map { |user| { id: user.id.to_s } }
      )
    end

    context "when not an admin" do
      let(:user) { create(:user) }

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
end
