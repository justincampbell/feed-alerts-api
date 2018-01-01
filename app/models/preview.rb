class Preview
  attr_reader :text

  def initialize(text)
    @text = text
  end

  def id
    @id ||= SecureRandom.uuid
  end
end
