namespace :feed_alerts do
  desc "Queue the periodic feed check job"
  task :queue_periodic_feed_check_job do
    PeriodicFeedCheckJob.perform_later
  end
end
