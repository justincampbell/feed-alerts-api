require 'net/http'

class Fetcher
  attr_reader :url

  def initialize(url: )
    @url = url
  end

  def cache_key
    [:fetcher, url].join('-')
  end

  def fetch
    body = Rails.cache.fetch(cache_key, expires_in: 10.minutes) {
      Net::HTTP.get_response(URI(url)).body
    }
    FeedResponse.new(body: body)
  end
end
