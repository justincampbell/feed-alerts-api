class VerificationCode < ApplicationRecord
  LENGTH = 4
  CHARACTERS = ("0".."9").to_a.freeze

  # TODO: Index table
  # TODO: Expire codes

  attribute :code, :string, default: -> { generate }

  def self.generate
    LENGTH.times.map { CHARACTERS.sample }.join
  end

  def self.store(destination)
    record = create(destination: destination)
    record.code
  end

  def self.verify(destination, code)
    where(destination: destination, code: code).exists?
  end
end
