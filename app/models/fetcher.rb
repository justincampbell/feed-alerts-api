require 'net/http'

class Fetcher
  attr_reader :url

  def initialize(url: )
    @url = url
  end

  def fetch
    response = Net::HTTP.get_response(URI(url))
    FeedResponse.new(body: response.body)
  end
end
