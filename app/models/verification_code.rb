class VerificationCode < ApplicationRecord
  CHARACTERS = ("0".."9").to_a.freeze
  LENGTH = 4
  TTL = 5.minutes

  # TODO: Index table

  attribute :code, :string, default: -> { generate }

  def self.generate
    LENGTH.times.map { CHARACTERS.sample }.join
  end

  def self.store(destination)
    record = create(destination: destination)
    record.code
  end

  def self.verify(destination, code)
    delete_expired
    matches = where(destination: destination, code: code)
    matches.exists?
  ensure
    matches.destroy_all
  end

  def self.delete_expired
    where("created_at < '#{TTL.ago}'").destroy_all
  end
end
