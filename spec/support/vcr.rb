VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/requests"
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.around :each, :vcr do |example|
    VCR.use_cassette(
      example.metadata[:full_description],
      &example
    )
  end
end
