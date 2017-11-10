require 'rails_helper'

RSpec.describe FeedsController do
  describe "#index" do
    it "returns empty data" do
      get "/feeds"

      expect(parsed_response).to include_json(
        data: []
      )
    end
  end
end
