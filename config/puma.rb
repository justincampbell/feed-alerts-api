threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

preload_app!

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  Que.worker_count = ENV.fetch("WORKER_CONCURRENCY") { 1 }
  Que.mode = :async
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
