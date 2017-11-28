class Feed < ApplicationRecord
  validates :name,
    presence: true

  validates :url,
    presence: true,
    url: true

  def fetch
    fetcher.fetch
  end

  def fetcher
    @fetcher ||= Fetcher.new(url: url)
  end
end
