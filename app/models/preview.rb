require 'securerandom'

class Preview
  attr_reader :feed_response

  def initialize(feed_response)
    @feed_response = feed_response
  end

  def id
    SecureRandom.uuid
  end

  def text
    feed_response.most_recent_item.text
  end
end
