require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def test
    end
  end

  describe "#current_user" do
    subject(:current_user) { controller.current_user }

    it { is_expected.to eq(nil) }

    context "with a valid token" do
      let(:user) { create(:user) }
      let(:token) { user.sessions.create.token }

      before { request.headers['Authorization'] = "Bearer #{token}" }

      it { is_expected.to eq(user) }
    end

    context "with a nonexistant token" do
      before { request.headers['Authorization'] = "Bearer a-token" }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#current_session" do
    subject(:current_session) { controller.current_session }

    it { is_expected.to eq(nil) }

    context "with a valid token" do
      let(:user) { create(:user) }
      let(:session) { user.sessions.create }
      let(:token) { session.token }

      before { request.headers['Authorization'] = "Bearer #{token}" }

      it { is_expected.to eq(session) }
    end

    context "with a nonexistant token" do
      before { request.headers['Authorization'] = "Bearer a-token" }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#token" do
    subject(:token) { controller.token }

    context "with a token" do
      before { request.headers['Authorization'] = "Bearer a-token" }
      it { is_expected.to eq("a-token") }
    end

    context "without a header" do
      it { is_expected.to eq(nil) }
    end

    context "with an invalid header" do
      before { request.headers['Authorization'] = "missing bearer prefix" }
      it { is_expected.to eq(nil) }
    end
  end
end
