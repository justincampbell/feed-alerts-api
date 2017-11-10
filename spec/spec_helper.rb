RSpec.configure do |config|
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.filter_run_when_matching :focus
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random
  Kernel.srand config.seed

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
