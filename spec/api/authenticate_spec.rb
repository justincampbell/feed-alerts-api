require 'rails_helper'

RSpec.describe AuthenticatesController do
  describe "#show" do
    context "with a valid token" do
      let(:user) { create(:user) }
      let(:token) { user.sessions.create.token }
      let(:headers) {
        { "Authorization" => "Bearer #{token}" }
      }

      it "returns the user" do
        get "/authenticate", headers: headers
        expect(response.status).to eq(200)
        expect(parsed_response).to include_json(
          data: {
            type: "users",
            id: user.id.to_s
          }
        )
      end
    end

    context "without a token" do
      it "returns not found" do
        get "/authenticate"
        expect(response.status).to eq(404)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Not found" }]
        )
      end
    end
  end

  describe "#destroy" do
    context "with a valid token" do
      let!(:session) { user.sessions.create }

      let(:user) { create(:user) }
      let(:token) { session.token }
      let(:headers) {
        { "Authorization" => "Bearer #{token}" }
      }

      it "deletes the session" do
        expect { 
          delete "/authenticate", headers: headers
        }.to change { user.sessions.count }.by(-1)

        expect(response.status).to eq(204)
      end
    end

    context "without a token" do
      it "returns no content" do
        delete "/authenticate"
        expect(response.status).to eq(204)
      end
    end
  end

  describe "#request_code" do
    let(:sms_number) { Faker::PhoneNumber.cell_phone }
    let(:normalized) { SMS.normalize(sms_number) }

    it "generates a code, stores it, and sends it to the number" do
      expect_any_instance_of(SMS)
        .to receive(:send)
        .with(normalized, anything)

      post "/authenticate/request-code", params: {
        sms_number: sms_number
      }

      expect(response.status).to eq(202)

      expect(VerificationCode.where(destination: normalized).count).to eq(1)
    end

    context "with an invalid phone number" do
      let(:sms_number) { "abc123" }

      it "responds with an error" do
        expect_any_instance_of(SMS)
          .to_not receive(:send)

        post "/authenticate/request-code", params: {
          sms_number: sms_number
        }

        expect(response.status).to eq(403)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Invalid SMS number" }]
        )

        expect(VerificationCode.where(destination: normalized).count).to eq(0)
      end
    end
  end

  describe "#create" do
    let(:sms_number) { Faker::PhoneNumber.cell_phone }
    let(:normalized_sms_number) { SMS.normalize(sms_number) }
    let(:verification_code) { VerificationCode.store(normalized_sms_number) }

    it "creates a user and returns a new session" do
      post "/authenticate", params: {
        sms_number: normalized_sms_number,
        verification_code: verification_code
      }

      expect(response.status).to eq(201)

      session = Session.first
      user = User.first
      expect(session.user).to eq(user)

      expect(parsed_response).to include_json(
        data: {
          id: session.id.to_s,
          type: "sessions",
          attributes: {
            token: session.token,
            expires_at: be_a(String)
          }
        }
      )
    end

    context "when the user already exists" do
      let(:user) { create(:user, sms_number: sms_number) }

      it "creates a user and returns a new session" do
        post "/authenticate", params: {
          sms_number: user.sms_number,
          verification_code: verification_code
        }

        expect(response.status).to eq(201)

        session = Session.first
        expect(session.user).to eq(user)

        expect(parsed_response).to include_json(
          data: {
            id: session.id.to_s,
            type: "sessions",
            attributes: {
              token: session.token,
              expires_at: be_a(String)
            }
          }
        )
      end
    end

    context "when the verification code does not match" do
      let(:verification_code) { "xxxx" }

      it "responds with an error" do
        post "/authenticate", params: {
          sms_number: sms_number,
          verification_code: verification_code
        }

        expect(response.status).to eq(403)
        expect(parsed_response).to include_json(
          errors: [{ detail: "Invalid verification code" }]
        )
      end
    end
  end
end
